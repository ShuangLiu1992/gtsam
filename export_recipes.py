import os
import subprocess
import platform

if __name__ == "__main__":
    cwd = os.path.dirname(os.path.realpath(__file__))
    target_list = ["Android", "Emscripten", platform.system()]
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
                subprocess.run(["conan", "editable", "add", f"{cwd}/conanfile.py", 
                                "--name", "gtsam", "--version", "gtsam", 
                                "--user", "editable", 
                                "--channel", f"{target}_{build_type}_{arch}", 
                                "--output-folder", f".build/{target}_{build_type}_{arch}"])
    subprocess.run(["conan", "export", f"{cwd}/conanfile.py", "--name", "gtsam", "--version", "gtsam"])
