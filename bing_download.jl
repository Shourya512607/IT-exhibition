using HTTP, Gumbo, Cascadia, Downloads, FilePaths

function duckduckgo_download(query::String, limit::Int, outdir::String)
    encoded_query = replace(query, " " => "+")
    url = "https://duckduckgo.com/?q=$(encoded_query)&iax=images&ia=images"

    # Fetch HTML
    resp = HTTP.get(url)
    html = String(resp.body)
    tree = parsehtml(html)

    # Grab image URLs from <img> tags
    img_nodes = eachmatch(Selector("img"), tree.root)
    mkpath(outdir)
    count = 0

    for node in img_nodes
        img_url = nothing
        if haskey(node.attributes, "src")
            img_url = node.attributes["src"]
        elseif haskey(node.attributes, "data-src")
            img_url = node.attributes["data-src"]
        else
            continue
        end

        # Skip base64
        if startswith(img_url, "data:")
            continue
        end

        # File extension
        ext = splitext(img_url)[2]
        if isempty(ext)
            ext = ".jpg"
        end

        file_path = joinpath(outdir, "img$(count)$(ext)")

        try
            Downloads.download(img_url, file_path)
            println("Saved: $file_path")
            count += 1
            sleep(0.2)
        catch e
            println("Failed: $img_url, Error: $e")
        end

        if count >= limit
            break
        end
    end
end

# Example usage
duckduckgo_download("person indoors", 150, "dataset/person")
duckduckgo_download("empty room indoors", 150, "dataset/no_person")
