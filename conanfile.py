from conan import ConanFile
from conan.tools.files import copy
from conan.tools.cmake import CMake, CMakeToolchain, cmake_layout
import os


class GTSAMConan(ConanFile):
    name = "gtsam"
    settings = "os", "build_type", "compiler", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "quaternion": [True, False]}
    default_options = {"shared": False, "fPIC": True, "quaternion": True}
    generators = "CMakeDeps"
    exports_sources = "gtsam_msvc.cmake",

    def requirements(self):
        self.requires(f"eigen/tag_4.29")
        self.requires(f"spectra/tag_3.23")
        self.requires(f"boost/1.82.0")

    def export_sources(self):
        copy(self, "*", self.recipe_folder, self.export_sources_folder)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.presets_prefix = f"{self.settings.os}_{self.settings.build_type}_{self.settings.arch}"
        if self.settings.os == "Windows":
            self.conf_info.define("tools.cmake.cmaketoolchain:user_toolchain", [f"{self.folders.base_build}/gtsam_msvc.cmake"])
        tc.variables["GTSAM_FORCE_SHARED_LIB"] = False
        tc.variables["GTSAM_USE_QUATERNIONS"] = self.options["quaternion"]
        tc.variables["GTSAM_ENABLE_TIMING"] = False
        tc.variables["GTSAM_THROW_CHEIRALITY_EXCEPTION"] = False
        tc.variables["GTSAM_USE_SYSTEM_EIGEN"] = True
        tc.variables['GTSAM_SLOW_BUT_CORRECT_BETWEENFACTOR'] = True
        tc.variables['GTSAM_BUILD_EXAMPLES_ALWAYS'] = False
        tc.variables['GTSAM_BUILD_TESTS'] = True
        tc.variables['GTSAM_WITH_TBB'] = False
        tc.variables["GTSAM_BUILD_TYPE_POSTFIXES"] = False
        tc.variables["GTSAM_USE_SYSTEM_METIS"] = True
        tc.variables["GTSAM_SUPPORT_NESTED_DISSECTION"] = False
        tc.variables["GTSAM_ENABLE_BOOST_SERIALIZATION"] = True
        tc.variables["GTSAM_USE_BOOST_FEATURES"] = True
        tc.variables["GTSAM_UNSTABLE_BUILD_PYTHON"] = False
        tc.generate()

    def layout(self):
        cmake_layout(self)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        cmake.install()

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "none")
        if self.settings.os == "Windows":
            self.cpp_info.builddirs.append(os.path.join(self.package_folder, "CMake"))
        else:
            self.cpp_info.builddirs.append(os.path.join(self.package_folder, "lib", "cmake"))
