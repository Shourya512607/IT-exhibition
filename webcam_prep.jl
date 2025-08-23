using OpenCV

# Open the webcam (0 = default camera)
cap = VideoCapture(0)

if !isopened(cap)
    error("Cannot open webcam")
end

println("Webcam successfully opened!")

# Warm up the webcam (optional but recommended)
println("Warming up webcam...")
for i in 1:30
    ret, frame = read(cap)
    if !ret
        println("Frame read failed at iteration $i")
        continue
    end
    # Resize frame to a standard size (optional)
    frame_resized = resize(frame, Size(640,480))
end

println("Webcam is ready for Python/TensorFlow code!")

# Optionally save a preview image
ret, frame = read(cap)
if ret
    imwrite("webcam_preview.jpg", frame)
    println("Saved preview image: webcam_preview.jpg")
end

# Release the camera if you just wanted to prep it
release(cap)
