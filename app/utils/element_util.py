import time

from selenium.webdriver.common.by import By
from selenium import webdriver


class Runnable:
    def run(self, arg):
        return True


def find_element(driver: webdriver, by: By, select: str, times: int = 5, transform: Runnable = None):
    times += 1
    element = None
    while not element or (transform and transform.run(element)):
        if times < 0:
            return False
        time.sleep(2)
        try:
            element = driver.find_element(by, select)
        except Exception:
            pass
        times -= 1
    return element
