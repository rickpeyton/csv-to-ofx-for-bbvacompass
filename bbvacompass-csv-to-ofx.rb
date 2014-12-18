require 'csv'
require 'date'

csv_filename = 'sample.csv'
ofx_filename = 'bbvacompass.OFX'
account_type = 'CHECKING'
account_number = '00000000'
routing_number = '062001186'

csv_contents = CSV.read(csv_filename)

available_balance = csv_contents[2][0].gsub(/[^\d^\.]/, '').to_f
posted_balance = csv_contents[2][1].gsub(/[^\d^\.]/, '').to_f
prior_balance = csv_contents[2][2].gsub(/[^\d^\.]/, '').to_f
statement_start_date = Date.strptime(csv_contents[4][0], '%m/%d/%Y')
statement_end_date = Date.strptime(csv_contents[4][1], '%m/%d/%Y')

File.open(ofx_filename, 'w') do |f|
  f.puts 'OFXHEADER:100'
  f.puts 'DATA:OFXSGML'
  f.puts 'VERSION:102'
  f.puts 'SECURITY:NONE'
  f.puts 'ENCODING:USASCII'
  f.puts 'CHARSET:1252'
  f.puts 'COMPRESSION:NONE'
  f.puts 'OLDFILEUID:NONE'
  f.puts 'NEWFILEUID:NONE'
  f.puts ''
  f.puts ' <OFX>'
  f.puts '   <SIGNONMSGSRSV1>'
  f.puts '     <SONRS>'
  f.puts '       <STATUS>'
  f.puts '         <CODE>0'
  f.puts '         <SEVERITY>INFO'
  f.puts '       </STATUS>'
  f.puts "       <DTSERVER>#{Time.now.strftime('%Y%m%d%H%M%S.%L')}"
  f.puts '       <LANGUAGE>ENG'
  f.puts '     </SONRS>'
  f.puts '   </SIGNONMSGSRSV1>'
  f.puts '    <BANKMSGSRSV1>'
  f.puts '      <STMTTRNRS>'
  f.puts "        <TRNUID>#{Time.now.strftime('%Y%m%d%H%M%S')}"
  f.puts '        <STATUS>'
  f.puts '          <CODE>0'
  f.puts '          <SEVERITY>INFO'
  f.puts '        </STATUS>'
  f.puts '        <STMTRS>'
  f.puts '          <CURDEF>USD'
  f.puts '          <BANKACCTFROM>'
  f.puts "            <BANKID>#{routing_number}"
  f.puts "            <ACCTID>#{account_number}"
  f.puts "            <ACCTTYPE>#{account_type}"
  f.puts '          </BANKACCTFROM>'
  f.puts '          <BANKTRANLIST>'
  f.puts "            <DTSTART>#{statement_start_date.strftime('%Y%m%d')}"
  f.puts "            <DTEND>#{statement_end_date.strftime('%Y%m%d')}"
  rows_to_skip = 6
  unique_fitid = 0
  csv_contents.each do |row|
    if rows_to_skip > 0
      rows_to_skip -= 1
    else
      transaction_amount = row[2].gsub(/[^-^\d^\.]/, '').to_f
      transaction_date = Date.strptime(row[0], '%m/%d/%Y').strftime('%Y%m%d')
      unique_fitid += 1
     if transaction_amount >= 0
       f.puts '            <STMTTRN>'
       f.puts '              <TRNTYPE>CREDIT'
       f.puts "              <DTPOSTED>#{transaction_date}"
       f.puts "              <DTUSER>#{transaction_date}"
       f.puts "              <TRNAMT>#{transaction_amount}"
       f.puts "              <FITID>#{Time.now.strftime('%Y%m%d')}#{unique_fitid}"
       f.puts "              <NAME>#{row[1].gsub(/([^\S])\1(CREDIT)/, '')}"
       f.puts '            </STMTTRN>'
     else
       f.puts '            <STMTTRN>'
       f.puts '              <TRNTYPE>PAYMENT'
       f.puts "              <DTPOSTED>#{transaction_date}"
       f.puts "              <DTUSER>#{transaction_date}"
       f.puts "              <TRNAMT>#{transaction_amount}"
       f.puts "              <FITID>#{Time.now.strftime('%Y%m%d')}#{unique_fitid}"
       f.puts "              <NAME>#{row[1].gsub(/([^\S])\1(DEBIT)/, '')}"
       f.puts '            </STMTTRN>'
     end
    end
  end
  f.puts '          </BANKTRANLIST>'
  f.puts '          <LEDGERBAL>'
  f.puts "            <BALAMT>#{posted_balance}"
  f.puts "            <DTASOF>#{Time.now.strftime('%Y%m%d%H%M%S.%L')}"
  f.puts '          </LEDGERBAL>'
  f.puts '          <AVAILBAL>'
  f.puts "            <BALAMT>#{available_balance}"
  f.puts "            <DTASOF>#{Time.now.strftime('%Y%m%d%H%M%S.%L')}"
  f.puts '          </AVAILBAL>'
  f.puts '        </STMTRS>'
  f.puts '      </STMTTRNRS>'
  f.puts '  </BANKMSGSRSV1>'
  f.puts '</OFX>'

end
