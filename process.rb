require 'csv'
require 'optparse'

# all possible columns that could be included to identify person
POSSIBLE_CLIENT_KEYS = ["sfid", "first name", "last name", "address",
                  "city", "state", "zip code", "email",
                  "mobile phone", "sms permission"]

def process_csv(input_file, output_file)
  clients = {}

  # Read the CSV and organize data by client
  CSV.foreach(input_file, headers: true) do |row|
    client_id = row[0]
    data = row.to_h

    # split the hash into client vs vehicle data (and map the arrays back into hashes)
    client_data, vehicle_data = data.partition { |key, _| POSSIBLE_CLIENT_KEYS.include? key }.map(&:to_h)
    # add person to array if not already exists (with empty vehicles)
    clients[client_id] ||= { client_data: client_data, vehicles: [] }
    # now add vehicle data for that person
    clients[client_id][:vehicles] << vehicle_data
  end

  # Identify the headers for the output file
  client_headers = clients.values.first[:client_data].keys
  vehicle_headers = clients.values.first[:vehicles].first.keys

  max_vehicles = clients.values.map { |data| data[:vehicles].size }.max

  # Build the repeated header strings (make_1, make_2, etc)
  vehicle_headers_repeated = (1..max_vehicles).map { |i| vehicle_headers.map { |header| "#{header} #{i}" } }.flatten

  # make a single array of ALL headers
  output_headers = client_headers + vehicle_headers_repeated

  # Write the output CSV
  CSV.open(output_file, "w") do |csv|
    csv << output_headers

    clients.each do |_, data|
      row = data[:client_data].values_at(*client_headers)
      data[:vehicles].each do |vehicle|
        row.concat(vehicle.values_at(*vehicle_headers))
      end
      # determine how many empty strings we need to fill the row
      empty_cell_count = (max_vehicles - data[:vehicles].size) * vehicle_headers.size
      array_of_empty_strings = Array.new(empty_cell_count) { '' }
      # now concat those empty cells to the end of the row
      row.concat(array_of_empty_strings)
      # finally add the row to the csv
      csv << row
    end
  end
end

# I'm using OptionParser to provide a little feedback to the user, and add some option validation
# (must have input and output specified)
options = {}
OptionParser.new do |opts|

  opts.on("-i", "--input FILE", "Input CSV file") do |v|
    options[:input] = v
  end

  opts.on("-o", "--output FILE", "Output CSV file") do |v|
    options[:output] = v
  end
end.parse!

if options[:input] && options[:output]
  process_csv(options[:input], options[:output])
else
  puts "Both input and output file paths are required."
  puts "Usage: process_report.rb -i input.csv -o output.csv"
end
