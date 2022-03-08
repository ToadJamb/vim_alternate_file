import re 
txt = 'the heyina in portugal runs toward the gazel'
x = re.search('^the.*gazel$', txt)
if x:
    print('yes we have a match')
else:
    print('no match')
###########################
txt = 'le sauvignon blanc est un bon vin a mon avis'
x = re.split('\s', txt)
print(x)
#########################################################
cars = ['evo','bmw','fiat']
print(cars)
#############################
food = ['chinese food','italian food','german food']
for x in food:
    print(x)

