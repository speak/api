module Speak
  class App < Sinatra::Base

    get '/recordings' do
      authenticate!
      archives = Archive.where(created_by: current_user.id)
      json :ok => true, :recordings => archives.map { |a| ArchiveSerializer.new(a).as_json }
    end

    get '/recordings/:id' do
      authenticate!
      archive = Archive.where(created_by: current_user.id).find(params[:id])
      json :ok => true, :recording => ArchiveSerializer.new(archive).as_json
    end

    get '/recordings/:id/download' do
      #redirect to an s3 bucket (v1 will be OT but that will change muhahah)
      authenticate!
      archive = Archive.find(params[:id])
      authorize! :read, archive
      redirect archive.url
    end

  end
end
