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

p available_balance
p posted_balance
p prior_balance
p statement_start_date
p statement_end_date

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

  f.puts '            <STMTTRN>'
  f.puts '              <TRNTYPE>CREDIT'
  f.puts '              <DTPOSTED>20070315'
  f.puts '              <DTUSER>20070315'
  f.puts '              <TRNAMT>200.00'
  f.puts '              <FITID>980315001'
  f.puts '              <NAME>DEPOSIT'
  f.puts '              <MEMO>automatic deposit'
  f.puts '            </STMTTRN>'
  f.puts '            <STMTTRN>'
  f.puts '              <TRNTYPE>CREDIT'
  f.puts '              <DTPOSTED>20070329'
  f.puts '              <DTUSER>20070329'
  f.puts '              <TRNAMT>150.00'
  f.puts '              <FITID>980310001'
  f.puts '              <NAME>TRANSFER'
  f.puts '              <MEMO>Transfer from checking'
  f.puts '            </STMTTRN>'
  f.puts '            <STMTTRN>'
  f.puts '              <TRNTYPE>PAYMENT'
  f.puts '              <DTPOSTED>20070709'
  f.puts '              <DTUSER>20070709'
  f.puts '              <TRNAMT>-100.00'
  f.puts '              <FITID>980309001'
  f.puts '                <CHECKNUM>1025'
  f.puts '              <NAME>John Hancock'
  f.puts '            </STMTTRN>'

  f.puts '          </BANKTRANLIST>'
  f.puts '          <LEDGERBAL>'
  f.puts "            <BALAMT>#{posted_balance}"
  f.puts '            <DTASOF>20071015021529.000[-8:PST]'
  f.puts '          </LEDGERBAL>'
  f.puts '          <AVAILBAL>'
  f.puts "            <BALAMT>#{available_balance}"
  f.puts '            <DTASOF>20071015021529.000[-8:PST]'
  f.puts '          </AVAILBAL>'
  f.puts '        </STMTRS>'
  f.puts '      </STMTTRNRS>'
  f.puts '  </BANKMSGSRSV1>'
  f.puts '</OFX>'

end
