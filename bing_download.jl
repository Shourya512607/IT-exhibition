using HTTP, Gumbo, Cascadia, Downloads, FilePaths
using OpenCV

# Person detection using HOG
hog = cvHOGDescriptor()
cvHOGDescriptorSetSVMDetector!(hog, cvHOGDescriptorGetDefaultPeopleDetector())

function is_person_image(path::String; threshold=0.5)
    img = imread(path)
    if img === nothing
        return false
    end
    rects, _ = cvHOGDetectMultiScale(hog, img)
    return length(rects) > 0
end

function bing_download(query::String, limit::Int, outdir::String)
    encoded_query = replace(query, " " => "+")
    url = "https://www.bing.com/images/search?q=$(encoded_query)&form=HDRSC2"

    resp = HTTP.get(url)
    html = String(resp.body)
    tree = parsehtml(html)
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

        if startswith(img_url, "data:")
            continue
        end

        ext = splitext(img_url)[2]
        if isempty(ext)
            ext = ".jpg"
        end
        file_path = joinpath(outdir, "img$(count)$(ext)")

        try
            Downloads.download(img_url, file_path)
            # Filter using person detector
            if query == "person indoors" && !is_person_image(file_path)
                rm(file_path)
                continue
            elseif query == "empty room indoors" && is_person_image(file_path)
                rm(file_path)
                continue
            end

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

# Usage
bing_download("person indoors", 150, "dataset/person")
bing_download("empty room indoors", 150, "dataset/no_person")
