import argparse
import csv
import math


def generate_csv_file(filename, duration, load_intensity_function):
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        for i in range(duration):
            timestamp = 0.5 + i
            load_intensity = load_intensity_function(i)  # Call user-specified function
            writer.writerow([timestamp, int(load_intensity)])

def main():
    parser = argparse.ArgumentParser(description='Generate a CSV file with load intensity data.')
    parser.add_argument('filename', type=str, help='Name of the csv file to be generated.')
    parser.add_argument('duration', type=int, help='Duration of intervals to generate in seconds.')
    parser.add_argument('function', type=str, help='Name of the function to generate load intensity data.')
    parser.add_argument('multiplier', type=int, help='Intensity multiplier.')
    parser.add_argument('peak_num', type=int, help='Number of peaks for sin function.')
    args = parser.parse_args()

    # Duration time argument
    duration = args.duration
    multiplier = args.multiplier
    peak_number = args.peak_num

    # Get the user-specified load intensity function
    if args.function == 'sin':
        load_intensity_function = lambda x: abs( multiplier * math.sin(2 * math.pi * x * (peak_number/2)/ duration) + 5)
    elif args.function == 'linear':
        load_intensity_function = lambda x: multiplier * x + 5
    else:
        print('Invalid function name. Use "sin" or "linear".')
        return

    # Generate the CSV file
    generate_csv_file(args.filename, duration, load_intensity_function)

if __name__ == '__main__':
    main()