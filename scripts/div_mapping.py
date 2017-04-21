def trailing_zeros(someint):
    str_int = str(someint)
    return len(str_int) - len(str_int.rstrip('0'))
    

def div_mapping(divisor):
    if divisor < 0:
        raise ValueError
    if divisor < 10:
        return '{:#04x}'.format(divisor)
    numzeros = trailing_zeros(divisor)
    exponent = numzeros
    if exponent >= 2**3:
        raise ValueError
    mantissa = int(divisor / (10**exponent))
    if mantissa >= 2**5:
        raise ValueError
    return '{:#04x}'.format((mantissa & 0x1F) << 3 | (exponent & 0x07))
    #hex((mantissa & 0x1F) << 3 | (exponent & 0x07))


def print_maplist(div_list):
    for el in div_list:
        print('({}, {}),'.format(el, div_mapping(el)))


map_list = [1,10,20,40,50,100,200,400,500,1000,2000,4000,5000,10000,20000,40000,50000,100000,200000,400000,500000,1000000]
 

if __name__ == '__main__':
    print('Testing Div Mapping')
    print(div_mapping(1))
    print(div_mapping(5))
    print(div_mapping(10))
    print(div_mapping(50))
    print(div_mapping(500000))
    print_maplist(map_list)
