require "time_logger_data_logging"

describe TimeLoggerDataLogging do

  def no_client_log
    username = "Test1"
    date = "2/15/2016"
    hours = "4"
    timecode = "PTO"
    @logger.log_time([username, date, hours, timecode, nil])
    [username, date, hours, timecode, nil]
  end

  def client_log
    username = "Test2"
    date = "2/10/2016"
    hours = "2"
    timecode = "Billable Work"
    client = "Bob"
    @logger.log_time([username, date, hours, timecode, client])
    [username, date, hours, timecode, client]
  end

  before do
    @file_name = "spec/test_files/timelog.csv"
    @employees_file_name = "spec/test_files/employees.csv"
    @clients_file_name = "spec/test_files/clients.csv"
    @logger = TimeLoggerDataLogging.new(time_log_file_name: @file_name,
                                        clients_file_name: @clients_file_name,
                                        employees_file_name: @employees_file_name)
    @logger.clear_data
  end

  it "can save username, date, hours, and timecode to default file" do
    recorded_data = no_client_log
    data = CSV.read(@file_name)
    expect(data[0]).to eql recorded_data
  end

  it "can save username, date, hours, timecode, and client to default file" do
    recorded_data = client_log
    data = CSV.read(@file_name)
    expect(data[0]).to eql recorded_data
  end

  it "can retrieve array of all rows" do
    no_client = no_client_log
    client = client_log
    data = @logger.read_time_log_data
    expect(data).to eql [no_client, client]
  end

  it "adds a default admin" do
    default_admin = TimeLoggerDataLogging.new(time_log_file_name: @file_name,
                                              clients_file_name: @clients_file_name,
                                              employees_file_name: @employees_file_name)
    data = CSV.read(@employees_file_name)
    expect(data[0]).to eql ["default_admin", "true"]
  end


  it "#add_employee" do
    employee = ["sasunday", "false"]
    @logger.add_employee(employee)
    data = CSV.read(@employees_file_name)
    expect(data[0]).to eql employee
  end

  it "#employee_names returns list of just employee_names" do
    employee1 = ["sasunday", "false"]
    employee2 = ["john", "true"]
    @logger.add_employee(employee1)
    @logger.add_employee(employee2)
    expect(@logger.employee_names).to eql [employee1[0], employee2[0]]
  end

  it "#add_client" do
    client_name = ["Generic Company Name"]
    @logger.add_client(client_name)
    data = CSV.read(@clients_file_name)
    expect(data[0]).to eql client_name
  end

  it "#client_names returns one-d array of client names" do
    client_name1 = ["Generic Company Name"]
    client_name2 = ["Foogle"]
    @logger.add_client(client_name1)
    @logger.add_client(client_name2)
    expect(@logger.client_names).to eql [client_name1[0], client_name2[0]]
  end

  it "#clear_client_file" do
    client_name = ["Generic Company Name"]
    @logger.add_client(client_name)
    @logger.clear_client_file
    expect(CSV.read(@clients_file_name).length).to eql 0
  end

  it "#clear_employees_file" do
    employee = ["sasunday", "false"]
    @logger.add_employee(employee)
    @logger.clear_employees_file
    expect(CSV.read(@employees_file_name).length).to eql 0
  end

end
