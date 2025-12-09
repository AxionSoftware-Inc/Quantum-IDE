class LauncherScript {
  static const String content = r'''
import sys
import io
import json
import base64
import matplotlib

# --- 1. WINDOWS UCHUN SUPER FIX (UTF-8) ---
# Windows konsoli "θ" harfini ko'tara olmaydi, shuning uchun majburlaymiz
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# GUI oyna ochilib ketmasligi uchun 'Agg' rejimiga o'tkazamiz
matplotlib.use('Agg') 
import matplotlib.pyplot as plt

# --- BIZNING AYG'OQCHI FUNKSIYALARIMIZ ---

def custom_show():
    """plt.show() o'rniga ishlaydigan funksiya"""
    try:
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight')
        buf.seek(0)
        img_str = base64.b64encode(buf.read()).decode('utf-8')
        
        # IDE ga rasm ma'lumotini yuboramiz
        data = {"bloch_image": img_str} # Aslida bu yerda ajratish kerak, lekin hozircha yetadi
        print("__DATA__: " + json.dumps(data))
        plt.close()
    except Exception as e:
        print(f"Vizualizatsiya xatosi: {e}")

# Matplotlibning asl show funksiyasini almashtirib qo'yamiz
plt.show = custom_show

# --- FOYDALANUVCHI KODINI YURGIZISH ---
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Xatolik: Kod fayli topilmadi.")
        sys.exit(1)
        
    user_script = sys.argv[1]
    
    try:
        # Foydalanuvchi kodini o'qiymiz (UTF-8 formatda)
        with open(user_script, 'r', encoding='utf-8') as f:
            code = f.read()
        
        # Global o'zgaruvchilar bilan ishga tushiramiz
        exec(code, globals())
        
    except Exception as e:
        # Xatolik bo'lsa chiroyli qilib chiqaramiz
        print(f"\n[Dastur Xatosi]: {e}")
''';
}