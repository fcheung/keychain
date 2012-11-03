
# Procotol constants for use when creating/finding a Keychain::Item of type internet password
#
#
module Keychain::Protocols
  # @private
  def self.attach_protocol name
    Sec.send :attach_variable, name, :pointer
    constant_name = name.to_s.gsub('kSecAttrProtocol', '').upcase
    const_set constant_name, CF::Base.typecast(Sec.send(name))
  end
  attach_protocol :kSecAttrProtocolFTP
  attach_protocol :kSecAttrProtocolFTPAccount
  attach_protocol :kSecAttrProtocolHTTP
  attach_protocol :kSecAttrProtocolIRC
  attach_protocol :kSecAttrProtocolNNTP
  attach_protocol :kSecAttrProtocolPOP3
  attach_protocol :kSecAttrProtocolSMTP
  attach_protocol :kSecAttrProtocolSOCKS
  attach_protocol :kSecAttrProtocolIMAP
  attach_protocol :kSecAttrProtocolLDAP
  attach_protocol :kSecAttrProtocolAppleTalk
  attach_protocol :kSecAttrProtocolAFP
  attach_protocol :kSecAttrProtocolTelnet
  attach_protocol :kSecAttrProtocolSSH
  attach_protocol :kSecAttrProtocolFTPS
  attach_protocol :kSecAttrProtocolHTTPS
  attach_protocol :kSecAttrProtocolHTTPProxy
  attach_protocol :kSecAttrProtocolHTTPSProxy
  attach_protocol :kSecAttrProtocolFTPProxy
  attach_protocol :kSecAttrProtocolSMB
  attach_protocol :kSecAttrProtocolRTSP
  attach_protocol :kSecAttrProtocolRTSPProxy
  attach_protocol :kSecAttrProtocolDAAP
  attach_protocol :kSecAttrProtocolEPPC
  attach_protocol :kSecAttrProtocolIPP
  attach_protocol :kSecAttrProtocolNNTPS
  attach_protocol :kSecAttrProtocolLDAPS
  attach_protocol :kSecAttrProtocolTelnetS
  attach_protocol :kSecAttrProtocolIMAPS
  attach_protocol :kSecAttrProtocolIRCS
  attach_protocol :kSecAttrProtocolPOP3S
end