require 'sinatra'
require './bina'
require 'pdfkit'
use PDFKit::Middleware
require "sinatra/basic_auth"
require 'sass'

require 'sinatra/reloader' if development?


# helper direktori sass
set :sass => '/views/css/'
set :port, 8080

get('/css/styles.css'){ scss :styles }

helpers do
	def css(*stylesheets)
		stylesheets.map do |stylesheet|
			"<link href=\"/css/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
		end.join
	end

	def current?(path='/')
		(request.path==path || request.path==path+'/') ? "current" : nil
	end
end

authorize "fkip" do |username, password|
  username == "fkip" && password == "12345"
end
authorize "hukum" do |username, password|
  username == "hukum" && password == "12345"
end
authorize "ekonomi" do |username, password|
  username == "ekonomi" && password == "12345"
end
authorize "fsip" do |username, password|
  username == "fsip" && password == "12345"
end
authorize "pertanian" do |username, password|
  username == "pertanian" && password == "12345"
end
authorize "kehutanan" do |username, password|
  username == "kehutanan" && password == "12345"
end
authorize "perikanan" do |username, password|
  username == "perikanan" && password == "12345"
end
authorize "teknik" do |username, password|
  username == "teknik" && password == "12345"
end
authorize "kedokteran" do |username, password|
  username == "kedokteran" && password == "12345"
end
authorize "mipa" do |username, password|
  username == "mipa" && password == "12345"
end


authorize "Admin" do |username, password|
  username == "admin" && password == "thebigboss"
end

get '/user' do
	erb :user
end

post '/cari' do

	@no_ujian = params[:noujian]
	@bina = Data_bina.all
	@binas = @bina.get(@no_ujian)

	if @binas == nil
		erb :hasil_nil
	elsif @binas.keterangan == "" || @binas.keterangan == nil
		erb :hasil_kosong
	else
		# kondisional jurusan
		if @binas.keterangan == "1"
			@jurusan = @binas.pilihan_1
			@fakultas =  @binas.fakultas_1
		else
			# @jurusan = "jurusan 2"
			@jurusan = @binas.pilihan_2
			@fakultas =  @binas.fakultas_2
		end
		erb :hasil_cari
	end		
end

get '/' do
	# if auth.credentials.first = 'nil'
		# erb :xlogin	
	# else
		erb :login	
end

get '/eror' do
	erb :xlogin
end

# proteksi user

protect "fkip" do
 	get '/fkip' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "hukum" do
 	get '/hukum' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "ekonomi" do
 	get '/ekonomi' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "fsip" do
 	get '/fsip' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "pertanian" do
 	get '/pertanian' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "kehutanan" do
 	get '/kehutanan' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "perikanan" do
 	get '/perikanan' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "teknik" do
 	get '/teknik' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "kedokteran" do
 	get '/kedokteran' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end

protect "mipa" do
 	get '/mipa' do
 		@authe = auth.credentials.first
		@authen = @authe.upcase
		erb :home
	end
end



# proteksi admin
protect "Admin" do
 	get '/admin' do
		erb :admin
	end

	get '/admin/tambah' do
		erb :tambah
	end

	post '/admin/tambah' do
		binas = Data_bina.new
		binas.no_ujian = params[:no_ujian]
		binas.nama = params[:nama]
		binas.pilihan_1 = params[:pilihan_1]
		binas.fakultas_1 = params[:fakultas_1]
		binas.pilihan_2 = params[:pilihan_2]
		binas.fakultas_2 = params[:fakultas_2]
		binas.keterangan = params[:keterangan]
		binas.jalur = params[:jalur]
		binas.save
		redirect to("/data/#{binas.no_ujian}")
	end
	get '/admin/tambah/:no_ujian' do
		@binas = Data_bina.get(params[:no_ujian])
		erb :simpan
	end

	post '/admin/cari' do
		@no_ujian = params[:noujian]
		@bina = Data_bina.all
		@binas = @bina.get(@no_ujian)
		erb :tampil_data
	end

	get '/admin/f1' do
		@authe = auth.credentials.first
		@authen = @authe.upcase
		# @binaf = Data_bina.all
		@binaf = Data_bina.all(:keterangan.like => '1') | Data_bina.all(:keterangan.like => '2')
		@binas = @binaf.all(:order => [:nilai.desc])
		erb :tampil_diterima
	end

	get '/admin/f0' do
		@authe = auth.credentials.first
		@authen = @authe.upcase
		@binaf = Data_bina.all  
		@binas = @binaf.all(:keterangan => '') | @binaf.all(:keterangan => nil)
		erb :main
	end
end



# tampilan

post '/data' do
	@no_ujian = params[:noujian]
	@authe = auth.credentials.first
	@authen = @authe.upcase
	@query = Data_bina.all(:fakultas_1 => @authen )| Data_bina.all(:fakultas_2 => @authen)

	@binas = @query.get(@no_ujian)
	# erb :tampil_data
	if @binas == nil
		erb :salah_pilih
	elsif @binas.keterangan == "" || @binas.keterangan == nil
		erb :tampil_data
	else
		# kondisional jurusan
		if @binas.keterangan == "1"
			@jurusan = @binas.pilihan_1
			@fakultas =  @binas.fakultas_1
		else
			# @jurusan = "jurusan 2"
			@jurusan = @binas.pilihan_2
			@fakultas =  @binas.fakultas_2
		end
		erb :tampil_modif
	end	
end

# definisikan rute2nya
# post '/data' do
# 	@authe = auth.credentials.first
# 	@authen = @authe.upcase
# 	@binas = Data_bina.all(:fakultas_1 => @authen )| Data_bina.all(:fakultas_2 => @authen)

# 	@binas = Data_bina.get(params[:noujian])
# 	# erb :tampil_data
# 	if @binas.keterangan == "" || @binas.keterangan == nil
# 		erb :tampil_data
# 	else
# 		# kondisional jurusan
# 		if @binas.keterangan == "1"
# 			@jurusan = @binas.pilihan_1
# 			@fakultas =  @binas.fakultas_1
# 		else
# 			# @jurusan = "jurusan 2"
# 			@jurusan = @binas.pilihan_2
# 			@fakultas =  @binas.fakultas_2
# 		end
# 		erb :tampil_modif
# 	end	
# end

# melakukan proses penyimpanan variable
post '/data/:no_ujian' do
	binas = Data_bina.get(params[:no_ujian])
	binas.keterangan = params[:keterangan]
	binas.nilai = params[:nilai]
	binas.jalur = params[:jalur]
	binas.save
	redirect to("/data/#{binas.no_ujian}")
end

# tampilan setelah variable berhasil di simpan
get '/data/:no_ujian' do
	@binas = Data_bina.get(params[:no_ujian])
	erb :simpan
end

# detail data yang sudah difilter
get '/detail' do
	@authe = auth.credentials.first
	@authen = @authe.upcase
	@bina = Data_bina.all(:fakultas_1 => @authen )| Data_bina.all(:fakultas_2 => @authen)
	erb :main
end


get '/detail/f1' do
	@authe = auth.credentials.first
	@authen = @authe.upcase
	@binaf = Data_bina.all(:fakultas_1 => @authen )| Data_bina.all(:fakultas_2 => @authen)  
	@binag = @binaf.all(:keterangan.like => '1') | @binaf.all(:keterangan.like => '2')
	@binas = @binag.all(:order => [:nilai.desc])

	erb :tampil_diterima
end

get '/detail/f0' do
	@authe = auth.credentials.first
	@authen = @authe.upcase
	@binaf = Data_bina.all(:fakultas_1 => @authen )| Data_bina.all(:fakultas_2 => @authen)  
	@binas = @binaf.all(:keterangan => '') | @binaf.all(:keterangan => nil)
	erb :main
end


# filterisasi pilihan

get '/p1' do
	@binas = Data_bina.all(:keterangan => '1')
	erb :main
end

get '/p2' do
	@binas = Data_bina.all(:keterangan => '2')
	erb :main
end

get '/p0' do
	@binas = Data_bina.all(:keterangan.like => '')| Data_bina.all(:keterangan => nil)
	erb :main
end

not_found do
	erb :kosong
end
