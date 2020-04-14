from threading import Condition, Thread, Lock, currentThread
import time
import random

condition = Condition()
queue = [] #TODO max size

class ConsumerThread(Thread):
  def __init__(self):
    Thread.__init__(self)
    print "Consumer was created ident: ", currentThread().ident

  def run(self):
      while True:
        condition.acquire()
        while not queue:
          print "..." # Nothing in queue, consumer is waiting
          condition.wait()
          #print "Producer added something to queue and notified the consumer"
   
        payload = queue.pop(0)
        print "Get notification. Payload:", payload
        condition.release()


class ProducerThread(Thread):
  def __init__(self, sleep_time=1):
    Thread.__init__(self)
    self.sleep_time = sleep_time
    print "Consumer was created ident: ", currentThread().ident

  def run(self):
      payloads = ["hello", "world", "i", "am", "payload"]
      while True:
        condition.acquire()
        payload = random.choice(payloads)
        queue.append(payload)
        print "Send notification. Payload: ", payload
        condition.notify()
        condition.release()
        time.sleep(self.sleep_time)


ProducerThread(sleep_time=1).start()
ConsumerThread().start()
