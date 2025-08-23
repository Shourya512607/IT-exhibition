import cv2
import numpy as np
from tensorflow.keras.models import load_model

# Load trained model
model = load_model("tiny_person_model.h5")

cap = cv2.VideoCapture(0)
light_on = False

def switch_light(status):
    global light_on
    light_on = status
    if status:
        print("[LIGHT] ON")
    else:
        print("[LIGHT] OFF")

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # Preprocess for CNN
    img = cv2.resize(frame, (32,32))
    img = img.astype("float32") / 255.0
    img = np.expand_dims(img, axis=0)
    
    # Predict
    pred = model.predict(img)
    person_detected = pred[0][0] > 0.5
    switch_light(person_detected)
    
    cv2.imshow("Electricity Saver", frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
