import json
from dotenv import load_dotenv
from firebase_admin import auth, initialize_app

load_dotenv('../.env')

initialize_app()

users = {}

for user in auth.list_users().iterate_all():
  users[user.uid] = {
    'uid': user.uid,
    'is_registered': user.email is not None,
    'created_at': user.user_metadata.creation_timestamp
  }

print(json.dumps(users))
