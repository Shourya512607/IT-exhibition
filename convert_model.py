import tensorflow as tf

# Load trained model
model = tf.keras.models.load_model("tiny_person_model.h5")

# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save optimized model
with open("tiny_person_model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Model converted and saved as tiny_person_model.tflite")
