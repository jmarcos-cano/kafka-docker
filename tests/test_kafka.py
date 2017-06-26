from pykafka import KafkaClient
from nose import with_setup
#{'test': None, 'DEVICE_EVENTS': None, 'DECORATED_DEVICE_EVENTS_SORTED_PER_DEVICE': None, 'DECORATED_DEVICE_EVENTS': None}


def multiply(a, b):
    """
    >>> multiply(4, 3)
    12
    >>> multiply('a', 3)
    'aaa'
    """
    return a * b


	
def setup():
	print "Connecting to Kafka Server"
	pass
	client = KafkaClient(hosts="127.0.0.1:9092")
	return client
	
	
@with_setup(setup)
def test_numbers_3_4():
    assert multiply(3,4) == 12
    print client.topics



#    #expected_json={'test': None, 'DEVICE_EVENTS': None, 'DECORATED_DEVICE_EVENTS_SORTED_PER_DEVICE': None, 'DECORATED_DEVICE_EVENTS': None}
#    assert True 





#print client.topics
