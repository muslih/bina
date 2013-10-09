require 'sinatra'
require './bina'
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


authorize "Admin" do |username, password|
  username == "admin" && password == "thebigboss"
end

get '/' do
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



get '/eror' do
	erb :xlogin
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


not_found do
	erb :kosong
end
