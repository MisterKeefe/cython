# mode: run
# tag: py3k_super

class A(object):
    def method(self):
        return 1

    @classmethod
    def class_method(cls):
        return 2

    @staticmethod
    def static_method():
        return 3

    def generator_test(self):
        return [1, 2, 3]


class B(A):
    """
    >>> obj = B()
    >>> obj.method()
    1
    >>> B.class_method()
    2
    >>> B.static_method(obj)
    3
    >>> list(obj.generator_test())
    [1, 2, 3]
    """
    def method(self):
        return super().method()

    @classmethod
    def class_method(cls):
        return super().class_method()

    @staticmethod
    def static_method(instance):
        return super().static_method()

    def generator_test(self):
        for i in super().generator_test():
            yield i


class C(A):
    """
    >>> obj = C()
    >>> obj.method_1()
    2
    >>> obj.method_2()
    3
    >>> obj.method_3()
    ['__class__', 'self']
    >>> obj.method_4()
    ['self']
    """
    
    def method_1(self):
        return __class__.class_method()

    def method_2(self):
        return __class__.static_method()

    def method_3(self):
        __class__
        return sorted(list(locals().keys()))

    def method_4(self):
        return sorted(list(locals().keys()))


class D:
    """
    >>> obj = D()
    >>> obj.method(1)
    1
    >>> obj.method(0)
    Traceback (most recent call last):
    ...
    UnboundLocalError: local variable '__class__' referenced before assignment
    """
    def method(self, x):
        if x: __class__ = x
        print(__class__)


class E:
    """
    >>> obj = E()
    >>> obj.method()()
    <class 'py3k_super.E'>
    """
    def method(self):
        def inner(): return __class__
        return inner


class F:
    """
    >>> obj = F()
    >>> obj.method()()()
    <class 'py3k_super.F'>
    """
    def method(self):
        def inner():
            def inner_inner():
                return __class__
            return inner_inner
        return inner


class G:
    """
    >>> obj = G()
    >>> obj.method()
    <class 'py3k_super.G.method.<locals>.H'>
    """
    def method(self):
        class H:
            def inner(self):
                return __class__
        return H().inner()


class I:
    """
    >>> obj = I()
    >>> obj.method()()()
    <class 'py3k_super.I.method.<locals>.inner.<locals>.J'>
    """
    def method(self):
        def inner():
            class J:
                def inner(self):
                    return __class__
            return J().inner
        return inner


class K:
    """
    >>> OldK = K
    >>> K = None
    >>> OldK().method().__name__
    'K'
    """
    def method(self): return __class__


def test_class_cell_empty():
    """
    >>> test_class_cell_empty()
    Traceback (most recent call last):
    ...
    SystemError: super(): empty __class__ cell
    """
    class Base(type):
        def __new__(cls, name, bases, attrs):
            attrs['foo'](None)

    class EmptyClassCell(metaclass=Base):
        def foo(self):
            super()


cdef class CClassBase(object):
    def method(self):
        return 'def'

#     cpdef method_cp(self):
#         return 'cpdef'
#     cdef method_c(self):
#         return 'cdef'
#     def call_method_c(self):
#         return self.method_c()

cdef class CClassSub(CClassBase):
    """
    >>> CClassSub().method()
    'def'
    """
#     >>> CClassSub().method_cp()
#     'cpdef'
#     >>> CClassSub().call_method_c()
#     'cdef'

    def method(self):
        return super().method()

#     cpdef method_cp(self):
#         return super().method_cp()
#     cdef method_c(self):
#         return super().method_c()
