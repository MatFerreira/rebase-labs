require 'csv'
require 'pg'
require 'uuid'


def insert_doctor(conn, doctor)
  query = "INSERT INTO doctors VALUES(#{doctor.join(', ')}) ON CONFLICT DO NOTHING"
  conn.exec(query)
end

def insert_patient(conn, patient)
  query = "INSERT INTO patients VALUES(#{patient.join(', ')}) ON CONFLICT DO NOTHING"
  conn.exec(query)
end

def insert_exam(conn, exam)
  query = "INSERT INTO medicalexams VALUES (#{exam.join(', ')})"
  conn.exec(query)
end

def main
  rows = CSV.read('./data.csv', col_sep: ';')
  columns = rows.shift
  begin
    conn = PG::Connection.new('localhost', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')
    conn.transaction do |con|
      rows.each do |row|
        uuid = UUID.new
        values = row.map { |v| "$$#{v}$$" }
        insert_patient(conn, values[0..6].unshift("$$#{uuid.generate}$$"))
        insert_doctor(conn, values[7..10].unshift("$$#{uuid.generate}$$"))
        patient_cpf = values[0]
        doctor_crm = values[7]
        exam = values[11..16].unshift("$$#{uuid.generate}$$", patient_cpf, doctor_crm)
        insert_exam(conn, exam)
      end
    end

    puts 'Sucesso'

  rescue PG::Error => e
    p e
    puts 'Perdão pelo vacilo'
  ensure
    conn&.close
  end
end

main()
