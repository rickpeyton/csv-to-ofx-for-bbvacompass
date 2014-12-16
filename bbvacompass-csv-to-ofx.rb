require 'csv'

csv_filename = 'sample.csv'

csv_contents = CSV.read(csv_filename)

p csv_contents
