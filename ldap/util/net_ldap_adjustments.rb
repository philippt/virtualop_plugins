require 'net/ldap'

# this is an ugly hack that we need because right now we're stuck with net/ldap 0.4
# and at least in 0.4, we cannot get the additional error information returned
# if the password does not match the password criteria defined in the ldap server
class MyLDAP < Net::LDAP
  
  attr_reader :last_error_message
  
  def modify args
    if @open_connection
        @result = @open_connection.modify( args )
        @last_error_message = @open_connection.last_error_message
    else
      @result = 0
      conn = Connection.new( :host => @host, :port => @port, :encryption => @encryption )
      if (@result = conn.bind( args[:auth] || @auth )) == 0
        @result = conn.modify( args )
        @last_error_message = conn.last_error_message
      end
      conn.close
    end
    @result == 0
  end

end

class Net::LDAP::Connection
  
  attr_reader :last_error_message
  
  def modify args
    modify_dn = args[:dn] or raise "Unable to modify empty DN"
    modify_ops = []
    a = args[:operations] and a.each {|op, attr, values|
      # TODO, fix the following line, which gives a bogus error
      # if the opcode is invalid.
      op_1 = {:add => 0, :delete => 1, :replace => 2} [op.to_sym].to_ber_enumerated
      modify_ops << [op_1, [attr.to_s.to_ber, values.to_a.map {|v| v.to_ber}.to_ber_set].to_ber_sequence].to_ber_sequence
    }

    request = [modify_dn.to_ber, modify_ops.to_ber_sequence].to_ber_appsequence(6)
    pkt = [next_msgid.to_ber, request].to_ber_sequence
    @conn.write pkt

    (be = @conn.read_ber(Net::LDAP::AsnSyntax)) && (pdu = Net::LdapPdu.new( be )) && (pdu.app_tag == 7) or raise LdapError.new( "response missing or invalid" )
    #puts "*** the pdu : #{pdu.result_code(:errorMessage)} ***"
    @last_error_message = pdu.result_code(:errorMessage)
    pdu.result_code
  end
  
end