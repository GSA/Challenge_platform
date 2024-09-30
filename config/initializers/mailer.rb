Mail.defaults do
  delivery_method :smtp,
    address: ENV["SMTP_SERVER"],
    port: (ENV["SMTP_PORT"] || 25).to_i, domain: "gsa.gov",
    openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
end
