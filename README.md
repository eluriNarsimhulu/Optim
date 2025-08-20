
# 🩺 Glaucoma Detection App (Flutter + PyTorch)

This project uses a **Vision Transformer (ViT)** model trained in PyTorch to classify eye fundus images into categories:  
- `Advanced Glaucoma`
- `Early Glaucoma`
- `Normal`

A **Flask API** serves the model predictions, and a **Flutter app** is used for the mobile interface.

---

## 🚀 How to Run the Project

### **1. Clone the Repository**
```bash
git clone https://github.com/alluramya1616/eye_clip.git
cd eye_clip
```

---

## **Backend (Flask + PyTorch) Setup**

### **2. Create a Python Virtual Environment(do it in project route folder)**
```bash
python -m venv venv
```
Activate it:
- **Windows (PowerShell)**
  ```bash
  venv\Scripts\activate
  ```
- **Mac/Linux**
  ```bash
  source venv/bin/activate
  ```

---

### **3. Install Python Dependencies**
```bash
pip install -r requirements.txt
```
### if any problem with installing pip install -r requirements.txt, do this :
```bash
pip install torch torchvision pillow requests flask
```
> Make sure `torch`, `torchvision`, and `flask` are in `requirements.txt`.

---

### **4. Start Flask Backend(cd models then )**
```bash
python app.py
```
It will start at:
```
http://0.0.0.0:5000/predict
```

---

## **Frontend (Flutter App) Setup**

### **5. Install Flutter Dependencies**
In a new terminal:
```bash
cd flutter_app_directory (eye_clip) # go into your Flutter folder
flutter pub get
```

---

### **6. Connect Flutter to Backend**
- If using **Android Emulator**:
  - Make sure in `detection_page.dart` you have:
    ```dart
    Uri.parse('http://10.0.2.2:5000/predict')
    ```
- If using **physical device**:
  - Replace `10.0.2.2` with your PC's IP (e.g., `192.168.1.5`(this ipv4 address appier in cmd when you run `ipconfig` copy that )) in `root/frontend/lib/pages/detection_page.dart`
  - Both PC and phone must be on **same Wi-Fi**.

---

### **7. Run Flutter App**
```bash
flutter run
```

---

## **8. Test the Prediction**
1. Select an eye image in the Flutter app.  
2. Click **Detect & Classify**.  
3. Flask backend will process it and send prediction back to app.  
4. A popup will show the predicted class & confidence score.

---

✅ **Tips for Friends**
- If Flask says "port already in use", change `5000` to something else in both `app.py` and Flutter code.  
- If they get **Failed host lookup** error on emulator → use `10.0.2.2` as explained above.  
- If on a phone, make sure firewall allows incoming connections on port **5000**.

---

💡 *Built with love using PyTorch, Flask, and Flutter.*