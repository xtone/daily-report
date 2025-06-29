module WebpackHelper
  def webpack_asset_path(name)
    manifest = load_manifest
    manifest[name] || "/packs/#{name}"
  end

  def javascript_pack_tag(name, **options)
    path = webpack_asset_path("#{name}.js")
    javascript_include_tag(path, **options)
  end

  def stylesheet_pack_tag(name, **options)
    path = webpack_asset_path("#{name}.css")
    stylesheet_link_tag(path, **options)
  end

  private

  def load_manifest
    @manifest ||= begin
      manifest_path = Rails.public_path.join('packs/manifest.json')
      if File.exist?(manifest_path)
        JSON.parse(File.read(manifest_path))
      else
        {}
      end
    end
  end
end
