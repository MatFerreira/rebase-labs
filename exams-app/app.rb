require 'sinatra/base'
require 'sinatra/cross_origin'
require 'pg'
require './import_from_csv'

class ExamApp < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, '3000'

  @@conn = PG::Connection.new('db', 5432, nil, nil, 'rebase-labs', 'postgres', 'password')

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/exams' do
    limit = params['limit'].to_i.abs
    page = params['page'].to_i.abs
    offset = (page - 1) * limit

    exams = @@conn.exec_params("SELECT DISTINCT
      exam_result_token, exam_date, patient_cpf, patients.name, patients.email, patients.birthdate, doctor_crm
      FROM medicalexams
      INNER JOIN patients ON cpf = patient_cpf LIMIT $1::int OFFSET $2::int", [(limit + 1), offset])

    return 404 if exams.ntuples == 0

    has_next = (exams.ntuples > limit)
    exam_list = (0..limit - 1).map do |n|
      exam = exams[n]
      tests = get_all_tests_by_result_token(exam['exam_result_token'])
      doctor = get_doctor_by_crm(exam['doctor_crm'])
      exam['doctor'] = doctor
      exam['tests'] = tests
      exam.delete('doctor_crm')
      exam
    end

    { data: exam_list, has_next: has_next }.to_json
  end

  get '/exams/:token' do
    result = @@conn.exec_params("SELECT DISTINCT
      exam_result_token, exam_date, patient_cpf, patients.name, patients.email, patients.birthdate, doctor_crm
      FROM medicalexams
      INNER JOIN patients ON cpf = patient_cpf
      WHERE exam_result_token = $1", [params[:token]])

    return 404 if result.ntuples == 0

    exam = result[0]
    tests = get_all_tests_by_result_token(exam['exam_result_token'])
    doctor = get_doctor_by_crm(exam['doctor_crm'])
    exam['doctor'] = doctor
    exam['tests'] = tests
    exam.delete('doctor_crm')
    exam.to_json
  end

  get '/' do
    erb :index
  end

  post '/import' do
    file = params[:csv_file][:tempfile]
    import_csv_data(file)
  end

  options '*' do
    response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end

  private

  def get_doctor_by_crm(crm)
    result = @@conn.exec_params('SELECT crm, crm_state, name, email FROM doctors where crm = $1::text', [crm])
    result[0]
  end

  def get_all_tests_by_result_token(token)
    result = @@conn.exec_params(
      'SELECT exam_type, exam_type_limits, exam_type_result from medicalexams where exam_result_token = $1::text', [token]
    )
    (0..result.ntuples - 1).map { |n| result[n] }
  end

  run!
end
