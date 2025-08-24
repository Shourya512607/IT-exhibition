import cv2
import numpy as np
import tensorflow as tf
import RPi.GPIO as GPIO
import time

# ---------------- Relay Setup ----------------
RELAYS = {
    "bulb1": 17,
    "bulb2": 27,
    "fan1": 22,
    "fan2": 23
}

GPIO.setmode(GPIO.BCM)
for pin in RELAYS.values():
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, GPIO.LOW)  # OFF at start

def switch_all(status):
    for device, pin in RELAYS.items():
        GPIO.output(pin, GPIO.HIGH if status else GPIO.LOW)
    print(f"[APPLIANCES] {'ON' if status else 'OFF'}")

# ---------------- Load TFLite Model ----------------
interpreter = tf.lite.Interpreter(model_path="tiny_person_model.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# ---------------- Camera ----------------
cap = cv2.VideoCapture(0)
appliances_on = False

try:
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Preprocess for CNN
        img = cv2.resize(frame, (32, 32))
        img = img.astype("float32") / 255.0
        img = np.expand_dims(img, axis=0)

        # Run TFLite inference
        interpreter.set_tensor(input_details[0]['index'], img)
        interpreter.invoke()
        pred = interpreter.get_tensor(output_details[0]['index'])

        person_detected = pred[0][0] > 0.5

        if person_detected and not appliances_on:
            switch_all(True)
            appliances_on = True
        elif not person_detected and appliances_on:
            switch_all(False)
            appliances_on = False

        # Show camera feed
        cv2.imshow("Electricity Saver", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

except KeyboardInterrupt:
    pass
finally:
    cap.release()
    cv2.destroyAllWindows()
    GPIO.cleanup()
