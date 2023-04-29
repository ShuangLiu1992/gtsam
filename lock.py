import platform
import os
import subprocess

if __name__ == "__main__":
    os_name = platform.system()
    cwd = os.path.dirname(os.path.realpath(__file__))
    target_list = [platform.system(), "Emscripten", "Android"]
    build_types = ["Release", "Debug"]
    arch_dict = {
        platform.system(): [{"AMD64": "x86_64", "arm64": "armv8"}.get(platform.machine(), platform.machine())],
        "Emscripten": ["wasm"],
        "Android": ["x86_64", "armv8"],
        "iOS": ["armv8"],
        "iOS_Simulator": ["x86_64"]
    }
    if platform.system() == "Darwin":
        target_list += ["iOS", "iOS_Simulator"]
    for target in target_list:
        for build_type in build_types:
            for arch in arch_dict[target]:
                build_setting = ["-s", f"build_type={build_type}", "-s", f"arch={arch}"]
                subprocess.run(["conan", "lock", "create",
                                f"{cwd}/conanfile.py", "--version", "gtsam",
                                "--user", "editable",
                                "--channel", f"{target}_{build_type}_{arch}",
                                f"-pr:b={os_name}Base", f"-pr:h={target}",
                                f"--lockfile-out=./.build/{target}_{build_type}_{arch}/lockfile",
                                "--build=missing", "--no-remote"] + build_setting)
