import cv2
import numpy as np
import tensorflow as tf
import RPi.GPIO as GPIO
import time

# GPIO setup
RELAY_PIN = 17  # You can change this GPIO pin
GPIO.setmode(GPIO.BCM)
GPIO.setup(RELAY_PIN, GPIO.OUT)
GPIO.output(RELAY_PIN, GPIO.LOW)

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path="tiny_person_model.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

cap = cv2.VideoCapture(0)

def switch_light(status):
    if status:
        GPIO.output(RELAY_PIN, GPIO.HIGH)
        print("[LIGHT] ON")
    else:
        GPIO.output(RELAY_PIN, GPIO.LOW)
        print("[LIGHT] OFF")

try:
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Preprocess for CNN
        img = cv2.resize(frame, (32,32))
        img = img.astype("float32") / 255.0
        img = np.expand_dims(img, axis=0)

        # Run inference
        interpreter.set_tensor(input_details[0]['index'], img)
        interpreter.invoke()
        pred = interpreter.get_tensor(output_details[0]['index'])

        person_detected = pred[0][0] > 0.5
        switch_light(person_detected)

        cv2.imshow("Electricity Saver (Raspberry Pi)", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

except KeyboardInterrupt:
    print("Exiting...")

finally:
    cap.release()
    cv2.destroyAllWindows()
    GPIO.cleanup()
