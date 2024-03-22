#include <iostream>
#include <vector>

int add(int a, int b)
{
    return a + b;
}

int main()
{
    std::cout << add(1, 2) << std::endl;
    std::vector<int> v;
    v.push_back(1);
    for (const auto& i : v)
        std::cout << i << std::endl;

    return 0;
}
