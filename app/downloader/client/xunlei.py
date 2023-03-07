import time

from pyvirtualdisplay import Display
from selenium import webdriver
from selenium.webdriver.common.by import By
from watchdog.utils.platform import is_linux, is_windows

import log
from app.downloader.client._base import _IDownloadClient
from app.utils.element_util import find_element, Runnable
from app.utils.types import DownloaderType
from config import Config


class DisabledElement(Runnable):
    def run(self, arg):
        return arg.get_attribute("class").__contains__("disabled")


class _XunleiInstance(_IDownloadClient):
    schema = "xunlei"
    client_type = DownloaderType.Xunlei.value

    host = None
    port = None

    def __init__(self, config=None):
        if config:
            _client_config = config
        else:
            _client_config = Config().get_config('xunlei')
        self.set_config(_client_config)
        self.connect()

    def set_config(self, _client_config):
        self.host = _client_config.get('host')
        self.port = int(_client_config.get('port')) if str(_client_config.get('port')).isdigit() else 4321

    def match(self, ctype):
        return True if ctype in [self.schema, self.client_type] else False

    driver = None
    display = None

    def connect(self):
        try:
            if not self.display and is_linux():
                self.display = Display(visible=is_windows(), size=(800, 800))
                self.display.start()
            if not self.driver:
                self.driver = webdriver.Chrome()
            if self.driver:
                self.driver.get(f"http://{self.host}:{self.port}")
        except Exception:
            self.driver = None
            self.display = None

    def __del__(self):
        if self.driver:
            self.driver.quit()
        if self.display:
            self.display.stop()

    def get_status(self):
        if self.driver:
            return True
        else:
            return False

    def get_torrents(self, ids, status, tag):
        pass

    def get_downloading_torrents(self, tag):
        pass

    def get_completed_torrents(self, tag):
        pass

    def set_torrents_status(self, ids, tags=None):
        pass

    def get_transfer_task(self, tag):
        pass

    def get_remove_torrents(self, config):
        pass

    def add_torrent(self, content):
        if not self.driver or not content:
            return False
        if not isinstance(content, str):
            log.error("【Brush】迅雷下载器暂不支持添加文件！")
            return False

        create_task = find_element(self.driver, By.CLASS_NAME, "create__task")
        if not create_task:
            log.error("【Xunlei】迅雷下载任务添加超时！（create__task）")
            self.driver.refresh()
            return False
        create_task.click()

        inner = find_element(self.driver, By.CLASS_NAME, "el-textarea__inner")
        if not inner:
            log.error("【Xunlei】迅雷下载任务添加超时！（el-textarea__inner）")
            self.driver.refresh()
            return False
        inner.send_keys(content)

        add_task = find_element(self.driver, By.CSS_SELECTOR,
                                ".nas-task-dialog .task-parse-btn", transform=DisabledElement())
        if not add_task:
            log.error("【Xunlei】迅雷下载任务添加超时！（.nas-task-dialog .task-parse-btn）")
            self.driver.refresh()
            return False
        add_task.click()

        confirm_task = find_element(self.driver, By.CSS_SELECTOR,
                                    ".result-nas-task-dialog .task-parse-btn", 30, DisabledElement())
        if not confirm_task:
            log.error("【Xunlei】迅雷下载任务添加超时！（.result-nas-task-dialog .task-parse-btn）")
            self.driver.refresh()
            return False
        confirm_task.click()

        time.sleep(5)
        self.driver.refresh()
        return int(round(time.time() * 1000))

    def start_torrents(self, ids):
        pass

    def stop_torrents(self, ids):
        pass

    def delete_torrents(self, delete_file, ids):
        pass

    def get_download_dirs(self):
        pass

    def change_torrent(self, **kwargs):
        pass

    def get_downloading_progress(self):
        pass

    def set_speed_limit(self, **kwargs):
        pass


class Xunlei(_IDownloadClient):
    _instance = None

    def __init__(self, config=None):
        if not Xunlei._instance:
            Xunlei._instance = _XunleiInstance()
        if config:
            Xunlei._instance.set_config(config)

    def match(self, ctype):
        return Xunlei._instance.match()

    def connect(self):
        Xunlei._instance.connect()

    def get_status(self):
        return Xunlei._instance.get_status()

    def get_torrents(self, ids, status, tag):
        return Xunlei._instance.get_torrents(ids, status, tag)

    def get_downloading_torrents(self, tag):
        return Xunlei._instance.get_downloading_torrents(tag)

    def get_completed_torrents(self, tag):
        return Xunlei._instance.get_completed_torrents(tag)

    def set_torrents_status(self, ids, tags=None):
        Xunlei._instance.set_torrents_status(ids, tags)

    def get_transfer_task(self, tag):
        return Xunlei._instance.get_transfer_task(tag)

    def get_remove_torrents(self, config):
        return Xunlei._instance.get_remove_torrents(config)

    def add_torrent(self, content):
        return Xunlei._instance.add_torrent(content)

    def start_torrents(self, ids):
        Xunlei._instance.start_torrents(ids)

    def stop_torrents(self, ids):
        Xunlei._instance.stop_torrents(ids)

    def delete_torrents(self, delete_file, ids):
        Xunlei._instance.stop_torrents(ids)

    def get_download_dirs(self):
        Xunlei._instance.get_download_dirs()

    def change_torrent(self, **kwargs):
        Xunlei._instance.change_torrent()

    def get_downloading_progress(self):
        Xunlei._instance.get_downloading_progress()

    def set_speed_limit(self, **kwargs):
        Xunlei._instance.set_speed_limit(**kwargs)
