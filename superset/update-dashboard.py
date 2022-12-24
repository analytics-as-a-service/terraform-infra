# new_zip_file = 'dashboard.zip'

# with open(new_zip_file, 'rb') as f:
#     payload = {
#         'passwords': '{"databases/replaceWithYourDatabase.yaml":"databasePassword"}',
#         'overwrite': 'true'
#     }
#     files = [
#         ('formData', ('dashboards.zip', f, 'application/zip'))
#     ]

#     print(f)

import os
import zipfile
import tempfile
from sys import argv

from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

def updateZip(zipname, outname, filenames, input_data):

    # generate a temp file
    tmpfd, tmpname = tempfile.mkstemp(dir=os.path.dirname(zipname))
    os.close(tmpfd)

    # store previous data
    previous_data = {}

    # create a temp copy of the archive without filename            
    with zipfile.ZipFile(zipname, 'r') as zin:
        with zipfile.ZipFile(tmpname, 'w') as zout:
            zout.comment = zin.comment # preserve the comment
            for item in zin.infolist():
                if item.filename not in filenames:
                    zout.writestr(item, zin.read(item.filename))
                else:
                    with zin.open(item.filename) as myfile:
                        previous_data[item.filename] = myfile.read()

                        data = load(previous_data[item.filename], Loader=Loader)
                        
                        for key in input_data:
                            if key in data:
                                data[key] = input_data[key]
                        
                        previous_data[item.filename] = dump(data, Dumper=Dumper)

    # rename with the temp archive
    os.rename(tmpname, outname)
    
    # now add filename with its new data
    with zipfile.ZipFile(outname, mode='a', compression=zipfile.ZIP_DEFLATED) as zf:
        for filename in filenames:
            zf.writestr(filename, previous_data[filename])


if __name__ == "__main__":
    user = argv[1]
    passwd = argv[2]
    db = argv[3]
    table = argv[4]
    host = argv[5]

    data = {
        "sqlalchemy_uri": f"mysql+mysqldb://{user}:{passwd}@{host}:3306/{db}",
        "table_name": table,
        "schema": db
    }

    print(data)
    updateZip('dashboard.zip', "output.zip", ['dashboard_export_20221224T112022/databases/BANK-DB.yaml', 'dashboard_export_20221224T112022/datasets/BANK-DB/transactions.yaml'], data)
