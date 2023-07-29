require 'csv'
require 'pg'

rows = CSV.read('./data.csv', col_sep: ';')
columns = rows.shift

begin
  conn = PG::Connection.new('localhost', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')
  conn.transaction do |con|
    rows.each do |row|
      values = row.map { |v| "$$#{v}$$" }.join(', ')
      query = "INSERT INTO medicalexams VALUES (#{values})"
      con.exec(query)
    end
  end

  puts 'Sucesso'

rescue PG::Error => e
  p e
  puts 'Perdão pelo vacilo'
ensure
  conn&.close
end
