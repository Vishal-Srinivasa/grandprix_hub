from flask_bcrypt import Bcrypt

bcrypt = Bcrypt()

password = input("Enter password: ")
hashed = bcrypt.generate_password_hash(password).decode('utf-8')
print("Hashed password: ", hashed)