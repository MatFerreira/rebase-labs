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

def import_csv_data(csv_file)
  rows = CSV.parse(csv_file, col_sep: ';')
  rows.shift

  conn = PG::Connection.new('db', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')
  conn.transaction do |_con|
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

  'Importado com sucesso'
rescue PG::Error => e
  "Erro de importação\n #{e}"
ensure
  conn&.close
end
