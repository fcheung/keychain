require 'openssl'

module Sec
  SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION = 0

  attach_function 'SecCertificateCopyPublicKey', [:pointer, :pointer], :osstatus
  attach_function 'SecCertificateCopyData', [:pointer], :pointer
  attach_function 'SecCertificateCopyValues', [:pointer, :pointer, :pointer], :pointer

  attach_variable 'kSecAttrCertificateType', :pointer
  attach_variable 'kSecAttrCertificateEncoding', :pointer
  attach_variable 'kSecAttrSubject', :pointer
  attach_variable 'kSecAttrIssuer', :pointer
  attach_variable 'kSecAttrSerialNumber', :pointer
  attach_variable 'kSecAttrSubjectKeyID', :pointer
  attach_variable 'kSecAttrPublicKeyHash', :pointer

  # OIDS
  attach_variable 'kSecOIDADC_CERT_POLICY', :pointer
  attach_variable 'kSecOIDAPPLE_CERT_POLICY', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_CODE_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_CODE_SIGNING_DEV', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_ICHAT_ENCRYPTION', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_ICHAT_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_RESOURCE_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EKU_SYSTEM_IDENTITY', :pointer
  attach_variable 'kSecOIDAPPLE_EXTENSION', :pointer
  attach_variable 'kSecOIDAPPLE_EXTENSION_ADC_APPLE_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EXTENSION_ADC_DEV_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EXTENSION_APPLE_SIGNING', :pointer
  attach_variable 'kSecOIDAPPLE_EXTENSION_CODE_SIGNING', :pointer
  attach_variable 'kSecOIDAuthorityInfoAccess', :pointer
  attach_variable 'kSecOIDAuthorityKeyIdentifier', :pointer
  attach_variable 'kSecOIDBasicConstraints', :pointer
  attach_variable 'kSecOIDBiometricInfo', :pointer
  attach_variable 'kSecOIDCSSMKeyStruct', :pointer
  attach_variable 'kSecOIDCertIssuer', :pointer
  attach_variable 'kSecOIDCertificatePolicies', :pointer
  attach_variable 'kSecOIDClientAuth', :pointer
  attach_variable 'kSecOIDCollectiveStateProvinceName', :pointer
  attach_variable 'kSecOIDCollectiveStreetAddress', :pointer
  attach_variable 'kSecOIDCommonName', :pointer
  attach_variable 'kSecOIDCountryName', :pointer
  attach_variable 'kSecOIDCrlDistributionPoints', :pointer
  attach_variable 'kSecOIDCrlNumber', :pointer
  attach_variable 'kSecOIDCrlReason', :pointer
  attach_variable 'kSecOIDDOTMAC_CERT_EMAIL_ENCRYPT', :pointer
  attach_variable 'kSecOIDDOTMAC_CERT_EMAIL_SIGN', :pointer
  attach_variable 'kSecOIDDOTMAC_CERT_EXTENSION', :pointer
  attach_variable 'kSecOIDDOTMAC_CERT_IDENTITY', :pointer
  attach_variable 'kSecOIDDOTMAC_CERT_POLICY', :pointer
  attach_variable 'kSecOIDDeltaCrlIndicator', :pointer
  attach_variable 'kSecOIDDescription', :pointer
  attach_variable 'kSecOIDEKU_IPSec', :pointer
  attach_variable 'kSecOIDEmailAddress', :pointer
  attach_variable 'kSecOIDEmailProtection', :pointer
  attach_variable 'kSecOIDExtendedKeyUsage', :pointer
  attach_variable 'kSecOIDExtendedKeyUsageAny', :pointer
  attach_variable 'kSecOIDExtendedUseCodeSigning', :pointer
  attach_variable 'kSecOIDGivenName', :pointer
  attach_variable 'kSecOIDHoldInstructionCode', :pointer
  attach_variable 'kSecOIDInvalidityDate', :pointer
  attach_variable 'kSecOIDIssuerAltName', :pointer
  attach_variable 'kSecOIDIssuingDistributionPoint', :pointer
  attach_variable 'kSecOIDIssuingDistributionPoints', :pointer
  attach_variable 'kSecOIDKERBv5_PKINIT_KP_CLIENT_AUTH', :pointer
  attach_variable 'kSecOIDKERBv5_PKINIT_KP_KDC', :pointer
  attach_variable 'kSecOIDKeyUsage', :pointer
  attach_variable 'kSecOIDLocalityName', :pointer
  attach_variable 'kSecOIDMS_NTPrincipalName', :pointer
  attach_variable 'kSecOIDMicrosoftSGC', :pointer
  attach_variable 'kSecOIDNameConstraints', :pointer
  attach_variable 'kSecOIDNetscapeCertSequence', :pointer
  attach_variable 'kSecOIDNetscapeCertType', :pointer
  attach_variable 'kSecOIDNetscapeSGC', :pointer
  attach_variable 'kSecOIDOCSPSigning', :pointer
  attach_variable 'kSecOIDOrganizationName', :pointer
  attach_variable 'kSecOIDOrganizationalUnitName', :pointer
  attach_variable 'kSecOIDPolicyConstraints', :pointer
  attach_variable 'kSecOIDPolicyMappings', :pointer
  attach_variable 'kSecOIDPrivateKeyUsagePeriod', :pointer
  attach_variable 'kSecOIDQC_Statements', :pointer
  attach_variable 'kSecOIDSerialNumber', :pointer
  attach_variable 'kSecOIDServerAuth', :pointer
  attach_variable 'kSecOIDStateProvinceName', :pointer
  attach_variable 'kSecOIDStreetAddress', :pointer
  attach_variable 'kSecOIDSubjectAltName', :pointer
  attach_variable 'kSecOIDSubjectDirectoryAttributes', :pointer
  attach_variable 'kSecOIDSubjectEmailAddress', :pointer
  attach_variable 'kSecOIDSubjectInfoAccess', :pointer
  attach_variable 'kSecOIDSubjectKeyIdentifier', :pointer
  attach_variable 'kSecOIDSubjectPicture', :pointer
  attach_variable 'kSecOIDSubjectSignatureBitmap', :pointer
  attach_variable 'kSecOIDSurname', :pointer
  attach_variable 'kSecOIDTimeStamping', :pointer
  attach_variable 'kSecOIDTitle', :pointer
  attach_variable 'kSecOIDUseExemptions', :pointer
  attach_variable 'kSecOIDX509V1CertificateIssuerUniqueId', :pointer
  attach_variable 'kSecOIDX509V1CertificateSubjectUniqueId', :pointer
  attach_variable 'kSecOIDX509V1IssuerName', :pointer
  attach_variable 'kSecOIDX509V1IssuerNameCStruct', :pointer
  attach_variable 'kSecOIDX509V1IssuerNameLDAP', :pointer
  attach_variable 'kSecOIDX509V1IssuerNameStd', :pointer
  attach_variable 'kSecOIDX509V1SerialNumber', :pointer
  attach_variable 'kSecOIDX509V1Signature', :pointer
  attach_variable 'kSecOIDX509V1SignatureAlgorithm', :pointer
  attach_variable 'kSecOIDX509V1SignatureAlgorithmParameters', :pointer
  attach_variable 'kSecOIDX509V1SignatureAlgorithmTBS', :pointer
  attach_variable 'kSecOIDX509V1SignatureCStruct', :pointer
  attach_variable 'kSecOIDX509V1SignatureStruct', :pointer
  attach_variable 'kSecOIDX509V1SubjectName', :pointer
  attach_variable 'kSecOIDX509V1SubjectNameCStruct', :pointer
  attach_variable 'kSecOIDX509V1SubjectNameLDAP', :pointer
  attach_variable 'kSecOIDX509V1SubjectNameStd', :pointer
  attach_variable 'kSecOIDX509V1SubjectPublicKey', :pointer
  attach_variable 'kSecOIDX509V1SubjectPublicKeyAlgorithm', :pointer
  attach_variable 'kSecOIDX509V1SubjectPublicKeyAlgorithmParameters', :pointer
  attach_variable 'kSecOIDX509V1SubjectPublicKeyCStruct', :pointer
  attach_variable 'kSecOIDX509V1ValidityNotAfter', :pointer
  attach_variable 'kSecOIDX509V1ValidityNotBefore', :pointer
  attach_variable 'kSecOIDX509V1Version', :pointer
  attach_variable 'kSecOIDX509V3Certificate', :pointer
  attach_variable 'kSecOIDX509V3CertificateCStruct', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionCStruct', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionCritical', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionId', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionStruct', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionType', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionValue', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionsCStruct', :pointer
  attach_variable 'kSecOIDX509V3CertificateExtensionsStruct', :pointer
  attach_variable 'kSecOIDX509V3CertificateNumberOfExtensions', :pointer
  attach_variable 'kSecOIDX509V3SignedCertificate', :pointer
  attach_variable 'kSecOIDX509V3SignedCertificateCStruct', :pointer
end

module Keychain
  class Certificate < Sec::Base
    register_type 'SecCertificate'

    ATTR_MAP = {CF::Base.typecast(Sec::kSecAttrAccessGroup) => :access_group,
                CF::Base.typecast(Sec::kSecAttrAccessible) => :accessible,
                CF::Base.typecast(Sec::kSecAttrCertificateType) => :certificate_type,
                CF::Base.typecast(Sec::kSecAttrCertificateEncoding) => :certificate_encoding,
                CF::Base.typecast(Sec::kSecAttrLabel) => :label,
                CF::Base.typecast(Sec::kSecAttrSubject) => :subject,
                CF::Base.typecast(Sec::kSecAttrIssuer) => :issuer,
                CF::Base.typecast(Sec::kSecAttrSerialNumber) => :serial_number,
                CF::Base.typecast(Sec::kSecAttrSynchronizable) => :synchronizable,
                CF::Base.typecast(Sec::kSecAttrSubjectKeyID) => :subject_key_id,
                CF::Base.typecast(Sec::kSecAttrPublicKeyHash) => :public_key_hash}

    ATTR_UPDATABLE = Set.new(ATTR_MAP.values)

    OID_MAP = {CF::Base.typecast(Sec::kSecOIDADC_CERT_POLICY) => 'ADC_CERT_POLICY',
               CF::Base.typecast(Sec::kSecOIDAPPLE_CERT_POLICY) => 'APPLE_CERT_POLICY',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_CODE_SIGNING) => 'APPLE_EKU_CODE_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_CODE_SIGNING_DEV) => 'APPLE_EKU_CODE_SIGNING_DEV',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_ICHAT_ENCRYPTION) => 'APPLE_EKU_ICHAT_ENCRYPTION',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_ICHAT_SIGNING) => 'APPLE_EKU_ICHAT_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_RESOURCE_SIGNING) => 'APPLE_EKU_RESOURCE_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EKU_SYSTEM_IDENTITY) => 'APPLE_EKU_SYSTEM_IDENTITY',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EXTENSION) => 'APPLE_EXTENSION',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EXTENSION_ADC_APPLE_SIGNING) => 'APPLE_EXTENSION_ADC_APPLE_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EXTENSION_ADC_DEV_SIGNING) => 'APPLE_EXTENSION_ADC_DEV_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EXTENSION_APPLE_SIGNING) => 'APPLE_EXTENSION_APPLE_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAPPLE_EXTENSION_CODE_SIGNING) => 'APPLE_EXTENSION_CODE_SIGNING',
               CF::Base.typecast(Sec::kSecOIDAuthorityInfoAccess) => 'AuthorityInfoAccess',
               CF::Base.typecast(Sec::kSecOIDAuthorityKeyIdentifier) => 'AuthorityKeyIdentifier',
               CF::Base.typecast(Sec::kSecOIDBasicConstraints) => 'BasicConstraints',
               CF::Base.typecast(Sec::kSecOIDBiometricInfo) => 'BiometricInfo',
               CF::Base.typecast(Sec::kSecOIDCSSMKeyStruct) => 'CSSMKeyStruct',
               CF::Base.typecast(Sec::kSecOIDCertIssuer) => 'CertIssuer',
               CF::Base.typecast(Sec::kSecOIDCertificatePolicies) => 'CertificatePolicies',
               CF::Base.typecast(Sec::kSecOIDClientAuth) => 'ClientAuth',
               CF::Base.typecast(Sec::kSecOIDCollectiveStateProvinceName) => 'CollectiveStateProvinceName',
               CF::Base.typecast(Sec::kSecOIDCollectiveStreetAddress) => 'CollectiveStreetAddress',
               CF::Base.typecast(Sec::kSecOIDCommonName) => 'CommonName',
               CF::Base.typecast(Sec::kSecOIDCountryName) => 'CountryName',
               CF::Base.typecast(Sec::kSecOIDCrlDistributionPoints) => 'CrlDistributionPoints',
               CF::Base.typecast(Sec::kSecOIDCrlNumber) => 'CrlNumber',
               CF::Base.typecast(Sec::kSecOIDCrlReason) => 'CrlReason',
               CF::Base.typecast(Sec::kSecOIDDOTMAC_CERT_EMAIL_ENCRYPT) => 'DOTMAC_CERT_EMAIL_ENCRYPT',
               CF::Base.typecast(Sec::kSecOIDDOTMAC_CERT_EMAIL_SIGN) => 'DOTMAC_CERT_EMAIL_SIGN',
               CF::Base.typecast(Sec::kSecOIDDOTMAC_CERT_EXTENSION) => 'DOTMAC_CERT_EXTENSION',
               CF::Base.typecast(Sec::kSecOIDDOTMAC_CERT_IDENTITY) => 'DOTMAC_CERT_IDENTITY',
               CF::Base.typecast(Sec::kSecOIDDOTMAC_CERT_POLICY) => 'DOTMAC_CERT_POLICY',
               CF::Base.typecast(Sec::kSecOIDDeltaCrlIndicator) => 'DeltaCrlIndicator',
               CF::Base.typecast(Sec::kSecOIDDescription) => 'Description',
               CF::Base.typecast(Sec::kSecOIDEKU_IPSec) => 'EKU_IPSec',
               CF::Base.typecast(Sec::kSecOIDEmailAddress) => 'EmailAddress',
               CF::Base.typecast(Sec::kSecOIDEmailProtection) => 'EmailProtection',
               CF::Base.typecast(Sec::kSecOIDExtendedKeyUsage) => 'ExtendedKeyUsage',
               CF::Base.typecast(Sec::kSecOIDExtendedKeyUsageAny) => 'ExtendedKeyUsageAny',
               CF::Base.typecast(Sec::kSecOIDExtendedUseCodeSigning) => 'ExtendedUseCodeSigning',
               CF::Base.typecast(Sec::kSecOIDGivenName) => 'GivenName',
               CF::Base.typecast(Sec::kSecOIDHoldInstructionCode) => 'HoldInstructionCode',
               CF::Base.typecast(Sec::kSecOIDInvalidityDate) => 'InvalidityDate',
               CF::Base.typecast(Sec::kSecOIDIssuerAltName) => 'IssuerAltName',
               CF::Base.typecast(Sec::kSecOIDIssuingDistributionPoint) => 'IssuingDistributionPoint',
               CF::Base.typecast(Sec::kSecOIDIssuingDistributionPoints) => 'IssuingDistributionPoints',
               CF::Base.typecast(Sec::kSecOIDKERBv5_PKINIT_KP_CLIENT_AUTH) => 'KERBv5_PKINIT_KP_CLIENT_AUTH',
               CF::Base.typecast(Sec::kSecOIDKERBv5_PKINIT_KP_KDC) => 'KERBv5_PKINIT_KP_KDC',
               CF::Base.typecast(Sec::kSecOIDKeyUsage) => 'KeyUsage',
               CF::Base.typecast(Sec::kSecOIDLocalityName) => 'LocalityName',
               CF::Base.typecast(Sec::kSecOIDMS_NTPrincipalName) => 'MS_NTPrincipalName',
               CF::Base.typecast(Sec::kSecOIDMicrosoftSGC) => 'MicrosoftSGC',
               CF::Base.typecast(Sec::kSecOIDNameConstraints) => 'NameConstraints',
               CF::Base.typecast(Sec::kSecOIDNetscapeCertSequence) => 'NetscapeCertSequence',
               CF::Base.typecast(Sec::kSecOIDNetscapeCertType) => 'NetscapeCertType',
               CF::Base.typecast(Sec::kSecOIDNetscapeSGC) => 'NetscapeSGC',
               CF::Base.typecast(Sec::kSecOIDOCSPSigning) => 'OCSPSigning',
               CF::Base.typecast(Sec::kSecOIDOrganizationName) => 'OrganizationName',
               CF::Base.typecast(Sec::kSecOIDOrganizationalUnitName) => 'OrganizationalUnitName',
               CF::Base.typecast(Sec::kSecOIDPolicyConstraints) => 'PolicyConstraints',
               CF::Base.typecast(Sec::kSecOIDPolicyMappings) => 'PolicyMappings',
               CF::Base.typecast(Sec::kSecOIDPrivateKeyUsagePeriod) => 'PrivateKeyUsagePeriod',
               CF::Base.typecast(Sec::kSecOIDQC_Statements) => 'QC_Statements',
               CF::Base.typecast(Sec::kSecOIDSerialNumber) => 'SerialNumber',
               CF::Base.typecast(Sec::kSecOIDServerAuth) => 'ServerAuth',
               CF::Base.typecast(Sec::kSecOIDStateProvinceName) => 'StateProvinceName',
               CF::Base.typecast(Sec::kSecOIDStreetAddress) => 'StreetAddress',
               CF::Base.typecast(Sec::kSecOIDSubjectAltName) => 'SubjectAltName',
               CF::Base.typecast(Sec::kSecOIDSubjectDirectoryAttributes) => 'SubjectDirectoryAttributes',
               CF::Base.typecast(Sec::kSecOIDSubjectEmailAddress) => 'SubjectEmailAddress',
               CF::Base.typecast(Sec::kSecOIDSubjectInfoAccess) => 'SubjectInfoAccess',
               CF::Base.typecast(Sec::kSecOIDSubjectKeyIdentifier) => 'SubjectKeyIdentifier',
               CF::Base.typecast(Sec::kSecOIDSubjectPicture) => 'SubjectPicture',
               CF::Base.typecast(Sec::kSecOIDSubjectSignatureBitmap) => 'SubjectSignatureBitmap',
               CF::Base.typecast(Sec::kSecOIDSurname) => 'Surname',
               CF::Base.typecast(Sec::kSecOIDTimeStamping) => 'TimeStamping',
               CF::Base.typecast(Sec::kSecOIDTitle) => 'Title',
               CF::Base.typecast(Sec::kSecOIDUseExemptions) => 'UseExemptions',
               CF::Base.typecast(Sec::kSecOIDX509V1CertificateIssuerUniqueId) => 'X509V1CertificateIssuerUniqueId',
               CF::Base.typecast(Sec::kSecOIDX509V1CertificateSubjectUniqueId) => 'X509V1CertificateSubjectUniqueId',
               CF::Base.typecast(Sec::kSecOIDX509V1IssuerName) => 'X509V1IssuerName',
               CF::Base.typecast(Sec::kSecOIDX509V1IssuerNameCStruct) => 'X509V1IssuerNameCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V1IssuerNameLDAP) => 'X509V1IssuerNameLDAP',
               CF::Base.typecast(Sec::kSecOIDX509V1IssuerNameStd) => 'X509V1IssuerNameStd',
               CF::Base.typecast(Sec::kSecOIDX509V1SerialNumber) => 'X509V1SerialNumber',
               CF::Base.typecast(Sec::kSecOIDX509V1Signature) => 'X509V1Signature',
               CF::Base.typecast(Sec::kSecOIDX509V1SignatureAlgorithm) => 'X509V1SignatureAlgorithm',
               CF::Base.typecast(Sec::kSecOIDX509V1SignatureAlgorithmParameters) => 'X509V1SignatureAlgorithmParameters',
               CF::Base.typecast(Sec::kSecOIDX509V1SignatureAlgorithmTBS) => 'X509V1SignatureAlgorithmTBS',
               CF::Base.typecast(Sec::kSecOIDX509V1SignatureCStruct) => 'X509V1SignatureCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V1SignatureStruct) => 'X509V1SignatureStruct',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectName) => 'X509V1SubjectName',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectNameCStruct) => 'X509V1SubjectNameCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectNameLDAP) => 'X509V1SubjectNameLDAP',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectNameStd) => 'X509V1SubjectNameStd',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectPublicKey) => 'X509V1SubjectPublicKey',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectPublicKeyAlgorithm) => 'X509V1SubjectPublicKeyAlgorithm',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectPublicKeyAlgorithmParameters) => 'X509V1SubjectPublicKeyAlgorithmParameters',
               CF::Base.typecast(Sec::kSecOIDX509V1SubjectPublicKeyCStruct) => 'X509V1SubjectPublicKeyCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V1ValidityNotAfter) => 'X509V1ValidityNotAfter',
               CF::Base.typecast(Sec::kSecOIDX509V1ValidityNotBefore) => 'X509V1ValidityNotBefore',
               CF::Base.typecast(Sec::kSecOIDX509V1Version) => 'X509V1Version',
               CF::Base.typecast(Sec::kSecOIDX509V3Certificate) => 'X509V3Certificate',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateCStruct) => 'X509V3CertificateCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionCStruct) => 'X509V3CertificateExtensionCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionCritical) => 'X509V3CertificateExtensionCritical',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionId) => 'X509V3CertificateExtensionId',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionStruct) => 'X509V3CertificateExtensionStruct',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionType) => 'X509V3CertificateExtensionType',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionValue) => 'X509V3CertificateExtensionValue',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionsCStruct) => 'X509V3CertificateExtensionsCStruct',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateExtensionsStruct) => 'X509V3CertificateExtensionsStruct',
               CF::Base.typecast(Sec::kSecOIDX509V3CertificateNumberOfExtensions) => 'X509V3CertificateNumberOfExtensions',
               CF::Base.typecast(Sec::kSecOIDX509V3SignedCertificate) => 'X509V3SignedCertificate',
               CF::Base.typecast(Sec::kSecOIDX509V3SignedCertificateCStruct) => 'X509V3SignedCertificateCStruct'}

    ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessible)] = :accessible if defined?(Sec::kSecAttrAccessible)
    ATTR_MAP[CF::Base.typecast(Sec::kSecAttrAccessControl)] = :access_control if defined?(Sec::kSecAttrAccessControl)

    INVERSE_ATTR_MAP = ATTR_MAP.invert
    define_attributes(ATTR_MAP)

    def klass
      Sec::Classes::CERTIFICATE.to_ruby
    end

    def public_key
      key_ref = FFI::MemoryPointer.new(:pointer)
      status = Sec.SecCertificateCopyPublicKey(self, key_ref)
      Sec.check_osstatus(status)

      Key.new(key_ref.read_pointer).release_on_gc
    end

    def x509
      data_ptr = Sec.SecCertificateCopyData(self)
      data = CF::Data.new(data_ptr)

      result = OpenSSL::X509::Certificate.new(data.to_s)
      data.release
      result
    end

    def contents
      @contents ||= begin
        data_ptr = Sec.SecCertificateCopyValues(self, nil, nil)
        data = CF::Dictionary.new(data_ptr)

        result = data.inject(Hash.new) do |hash, pair|
          # Get human readable key
          key = pair.first
          human_key = OID_MAP[key] || key.to_ruby

          value = pair.last

          # Map values to ruby hash
          human_value = value.to_ruby

          # Store current result
          hash[human_key] = human_value

          # Now fix labels
          fix_label(human_value, value)
          value['value'].each_with_index do |oid_value, index|
            fix_label(human_value['value'][index], oid_value)
          end

          hash
        end

        data.release
        result
      end
    end

    def fix_label(ruby_dictionary, cf_dictionary)
      label = cf_dictionary['label']
      return unless label
      ruby_dictionary['label'] = OID_MAP[label] || label.to_ruby
    end

    def valid?
      self.start < Time.now && self.finish > Time.now
    end

    def start
      hash = self.contents['X509V1ValidityNotBefore']
      to_time(hash['value'])
    end

    def finish
      hash = self.contents['X509V1ValidityNotAfter']
      to_time(hash['value'])
    end

    def to_time(value)
      # Returned times are NSDates which use 00:00:00 UTC on 1 January 2001 as the reference time
      reference_time = Time.new(2001, 1, 1, 0, 0, 0, 0)
      Time.at(value + reference_time.to_i)
    end
  end
end