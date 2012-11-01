
# Procotol constants for use when creating/finding a Keychain::Item of type internet password
#
#
#
module Keychain::Protocols
  def self.attach_protocal name
    Sec.send :attach_variable, name, :pointer
    constant_name = name.to_s.gsub('kSecAttrProtocol', '').upcase
    const_set constant_name, CF::Base.typecast(Sec.send(name))
  end
  attach_protocal :kSecAttrProtocolFTP
  attach_protocal :kSecAttrProtocolFTPAccount
  attach_protocal :kSecAttrProtocolHTTP
  attach_protocal :kSecAttrProtocolIRC
  attach_protocal :kSecAttrProtocolNNTP
  attach_protocal :kSecAttrProtocolPOP3
  attach_protocal :kSecAttrProtocolSMTP
  attach_protocal :kSecAttrProtocolSOCKS
  attach_protocal :kSecAttrProtocolIMAP
  attach_protocal :kSecAttrProtocolLDAP
  attach_protocal :kSecAttrProtocolAppleTalk
  attach_protocal :kSecAttrProtocolAFP
  attach_protocal :kSecAttrProtocolTelnet
  attach_protocal :kSecAttrProtocolSSH
  attach_protocal :kSecAttrProtocolFTPS
  attach_protocal :kSecAttrProtocolHTTPS
  attach_protocal :kSecAttrProtocolHTTPProxy
  attach_protocal :kSecAttrProtocolHTTPSProxy
  attach_protocal :kSecAttrProtocolFTPProxy
  attach_protocal :kSecAttrProtocolSMB
  attach_protocal :kSecAttrProtocolRTSP
  attach_protocal :kSecAttrProtocolRTSPProxy
  attach_protocal :kSecAttrProtocolDAAP
  attach_protocal :kSecAttrProtocolEPPC
  attach_protocal :kSecAttrProtocolIPP
  attach_protocal :kSecAttrProtocolNNTPS
  attach_protocal :kSecAttrProtocolLDAPS
  attach_protocal :kSecAttrProtocolTelnetS
  attach_protocal :kSecAttrProtocolIMAPS
  attach_protocal :kSecAttrProtocolIRCS
  attach_protocal :kSecAttrProtocolPOP3S
end