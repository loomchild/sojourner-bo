require "google/cloud/storage"

class FirebaseStorageService
  def initialize
    storage = Google::Cloud::Storage.new
    @bucket = storage.bucket "#{ENV['FIRESTORE_PROJECT']}.appspot.com"
  end

  def download(path)
    file = @bucket.file(path)
    file.download
  end
end
