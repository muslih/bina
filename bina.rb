require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'

# configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/binalingkungan.db")
# end

class Data_bina
	include DataMapper::Resource
	property :id, Integer
	property :no_ujian, String, key: true, unique_index: true
	property :nama, String
	property :nama_sekolah, String
	property :pilihan_1, String
	property :fakultas_1, String
	property :pilihan_2, String
	property :fakultas_2, String
	property :benar, String
	property :nilai, String
	property :keterangan, String
	property :jalur, String
	property :coba, String

	def released_on=date
		super Date.strptime(date, '%m/%d/%Y')
	end
end

DataMapper.finalize
# DataMapper.auto_upgrade!	

