import zipfile, os, sys

zip_path = sys.argv[1]
outdir = os.getcwd()

with zipfile.ZipFile(zip_path, 'r') as z:
    for name in z.namelist():
        norm = name.replace('\\', '/')
        dst = os.path.join(outdir, norm)
        if norm.endswith('/'):
            os.makedirs(dst, exist_ok=True)
        else:
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            data = z.read(name)
            with open(dst, 'wb') as f:
                f.write(data)
