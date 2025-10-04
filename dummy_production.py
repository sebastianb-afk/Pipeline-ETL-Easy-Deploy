import os
import sys

def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[0]
    less = [x for x in arr[1:] if x < pivot]
    equal = [pivot]
    greater = [x for x in arr[1:] if x >= pivot]

    return quicksort(less) + equal + quicksort(greater)
    
def quicksort_chars(text):
    cleaned_text = text.replace(' ', '')
    chars = list(cleaned_text)
    sorted_chars = quicksort(chars)
    result = "".join(sorted_chars)
    return result

def process(input_file, output_file):
    with open(input_file, "r", encoding="utf-8") as f:
        data = f.read()
        processed = quicksort_chars(data)
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(processed)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python processor.py <input> <output>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process(input_file, output_file)