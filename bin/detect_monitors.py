import subprocess


def get_screens():
    output = [
        screen
        for screen in subprocess.check_output(['xrandr']).decode('utf-8').splitlines()
    ]
    return [screen.split()[0] for screen in output if ' connected ' in screen]


screens = get_screens()
if len(screens) == 1:
    # Set keyboard es layout
    subprocess.call('setxkbmap -layout es', shell=True)
