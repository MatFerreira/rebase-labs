require 'sinatra'
require 'rack/handler/puma'
require 'csv'
require 'pg'

conn = PG::Connection.new('localhost', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')

def get_doctor_by_crm(conn, crm)
  result = conn.exec_params('SELECT * FROM doctors where crm = $1::text', [crm])
  result[0]
end

def get_all_tests_by_result_token(conn, token)
  result = conn.exec_params('SELECT exam_type, exam_type_limits, exam_type_result from medicalexams where exam_result_token = $1::text', [token])
  (0..result.ntuples - 1).map { |n| result[n] }
end

get '/exams' do
  limit = params['limit'].to_i
  page = params['page'].to_i
  offset = (page - 1) * limit
  has_next = false

  exams = conn.exec_params("SELECT DISTINCT
    exam_result_token, exam_date, patient_cpf, patients.name, patients.email, patients.birthdate, doctor_crm
    FROM medicalexams
    INNER JOIN patients ON cpf = patient_cpf LIMIT $1::int OFFSET $2::int", [(limit + 1), offset])

  if (exams.ntuples > limit)
    has_next = true
  end

  exam_list = (0..limit - 1).map do |n|
    exam = exams[n]
    tests = get_all_tests_by_result_token(conn, exam['exam_result_token'])
    doctor = get_doctor_by_crm(conn, exam['doctor_crm'])
    exam['doctor'] = doctor
    exam['tests'] = tests
    exam
  end

  { data: exam_list, has_next: has_next}.to_json
end

get '/' do
  erb :index
end

Rack::Handler::Puma.run(
  Sinatra::Application,
  Port: 3000,
  Host: '0.0.0.0'
)
