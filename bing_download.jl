using HTTP, Gumbo, Cascadia, Downloads, FilePaths

function bing_download(query::String, limit::Int, outdir::String)
    encoded_query = replace(query, " " => "+")
    url = "https://www.bing.com/images/search?q=$(encoded_query)&form=HDRSC2"

    # Fetch HTML
    resp = HTTP.get(url)
    html = String(resp.body)

    # Parse HTML
    tree = parsehtml(html)

    # Find image nodes
    img_nodes = eachmatch(Selector("img"), tree.root)

    mkpath(outdir)

    count = 0
    for node in img_nodes
        img_url = nothing

        if haskey(node.attributes, "src")
            img_url = node.attributes["src"]
        elseif haskey(node.attributes, "data-src")
            img_url = node.attributes["data-src"]
        elseif haskey(node.attributes, "data-src-hq")
            img_url = node.attributes["data-src-hq"]
        else
            continue
        end

        # Skip inline base64
        if startswith(img_url, "data:")
            continue
        end

        # Pick extension (default .jpg)
        ext = splitext(img_url)[2]
        if isempty(ext)
            ext = ".jpg"
        end
        file_path = joinpath(outdir, "img$(count)$(ext)")

        try
            Downloads.download(img_url, file_path)
            println("Saved: $file_path")
            count += 1
            sleep(0.2)  # avoid hammering server
        catch e
            println("Failed: $img_url, Error: $e")
        end

        if count >= limit
            break
        end
    end
end

# Example usage
bing_download("person indoors", 150, "dataset/person")
bing_download("empty room indoors", 150, "dataset/no_person")
