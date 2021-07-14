import shutil
import sys
import os

# Drop source directory from PYTHONPATH
from argparse import ArgumentParser

sys.path.pop(0)

PROJECT_MODULE = "mc_lib"
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))


def main(argv):
    print(ROOT_DIR)
    parser = ArgumentParser()
    parser.add_argument("--verbose", "-v", action="count", default=1,
                        help="more verbosity")
    parser.add_argument("--tests", "-t", action='append', help="Specify tests to run")

    args = parser.parse_args(argv)

    test_dir = os.path.join(ROOT_DIR, 'build', 'test')
    if not os.path.isdir(test_dir):
        os.makedirs(test_dir)
    print(os.path.join(ROOT_DIR))
    print(os.path.join(test_dir))

    cwd = os.getcwd()
    try:
        __import__(PROJECT_MODULE)
        test = sys.modules[PROJECT_MODULE].test
        os.chdir(test_dir)
        result = test(verbose=args.verbose)
    finally:
        os.chdir(cwd)

    if isinstance(result, bool):
        sys.exit(0 if result else 1)
    elif result.wasSuccessful():
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main(argv=sys.argv[1:])
