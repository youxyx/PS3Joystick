import pygame
import time
import math

class Joystick:
    def __init__(self):
        # 初始化原生PS3蓝牙手柄
        pygame.init()
        pygame.joystick.init()
        
        # 等待PS3手柄连接
        while pygame.joystick.get_count() == 0:
            time.sleep(0.5)
        
        self.joystick = pygame.joystick.Joystick(0)
        self.joystick.init()
        
        # 死区配置（和原PS4一致）
        self.deadzone = 0.14

    def _deadzone_filter(self, x, y):
        if math.sqrt(x**2 + y**2) < self.deadzone:
            return 0.0, 0.0
        return x, y

    def get_input(self):
        pygame.event.pump()
        vals = {}

        # 摇杆（严格匹配原PS4键名）
        vals["left_analog_x"], vals["left_analog_y"] = self._deadzone_filter(
            self.joystick.get_axis(0), -self.joystick.get_axis(1)
        )
        vals["right_analog_x"], vals["right_analog_y"] = self._deadzone_filter(
            self.joystick.get_axis(2), -self.joystick.get_axis(3)
        )

        # 扳机键
        vals["l2_analog"] = (self.joystick.get_axis(4) + 1) / 2
        vals["r2_analog"] = (self.joystick.get_axis(5) + 1) / 2

        # 肩部按键
        vals["button_l1"] = self.joystick.get_button(4)
        vals["button_r1"] = self.joystick.get_button(5)

        # 功能键 □×○△
        vals["button_square"] = self.joystick.get_button(0)
        vals["button_cross"] = self.joystick.get_button(1)
        vals["button_circle"] = self.joystick.get_button(2)
        vals["button_triangle"] = self.joystick.get_button(3)

        # PS键
        vals["button_ps"] = self.joystick.get_button(16)

        # 方向键
        hat = self.joystick.get_hat(0)
        vals["dpad_up"] = 1 if hat[1] == 1 else 0
        vals["dpad_down"] = 1 if hat[1] == -1 else 0
        vals["dpad_right"] = 1 if hat[0] == 1 else 0
        vals["dpad_left"] = 1 if hat[0] == -1 else 0

        # 时间戳（兼容原格式）
        vals["timestamp"] = time.time()
        return vals

    # PS3无LED，空实现兼容原代码
    def led_color(self, red=0, green=0, blue=0):
        pass

    # PS3无震动，空实现兼容原代码
    def rumble(self, small=0, big=0):
        pass

    def map(self, val, in_min, in_max, out_min, out_max):
        return max(out_min, min(out_max, (val - in_min) * (out_span / (in_max - in_min)) + out_min))

    def close(self):
        pass

    def __del__(self):
        self.close()

if __name__ == "__main__":
    j = Joystick()
    while 1:
        print(j.get_input())
        time.sleep(0.1)
