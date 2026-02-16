% Psychophysiology Learning Resources - Germano Gallicchio
% https://germanogallicchio.github.io/learning/

%% Display text on screen

disp('Hello, World!')

% try to change the string of text to display a different text

% this is a comment... 
% lines starting with the percentage symbol are not executed by MATLAB

%% Display a number on the screen

disp(42)

%% Display text and number on the screen

% dont worry about the square brackets--they will be explained later
disp(['Hello, World!' 42])


% the code does not behave as we expected
% this is because we are mixing two data types: string and numbers (double)
% the solution is to convert the number 42 to string by using the function
% str2num().
% disp() is another function.
% There are many "functions" and we can even create our own... more to come

%% Basic arithmetic operations

a = 5;
b = 3;

% Addition
c = a + b;
disp(['Addition: ', num2str(c)])

% Subtraction
c = a - b;
disp(['Subtraction: ', num2str(c)])

% Multiplication
c = a * b;
disp(['Multiplication: ', num2str(c)])

% Division
c = a / b;
disp(['Division: ', num2str(c)])

% Exponentiation
c = a ^ b;
disp(['Exponentiation: ', num2str(c)])

%% Variables and Data Types
% This cell explains variables and different data types in MATLAB.

% Variables are used to store data. 
% Variable names must start with a letter

x = 10; % Integer
y = pi; % Floating-point number
z = 'Hello'; % String
w = true; % Boolean

disp(['Integer: ', num2str(x)])
disp(['Floating-point: ', num2str(y)])
disp(['String: ', z])
disp(['Boolean: ', num2str(w)])

%% Vectors and Matrices
% This cell introduces vectors and matrices, which are fundamental in MATLAB.
% MATLAB itself stands for MATrix LABoratory.

% Row vector
rowVec = [1, 2, 3, 4, 5];
disp('Row Vector:')
disp(rowVec)

% Column vector
colVec = [1; 2; 3; 4; 5];
disp('Column Vector:')
disp(colVec)

% Matrix
mat = [1, 2, 3; 4, 5, 6; 7, 8, 9];
disp('Matrix:')
disp(mat)

%% Vector sequences
% 1. create a variable called "sequence" with a sequence of numbers
% 2. remove the semi colon to see the content of the variable just created
% (as alternative to the disp() function)
% 3. create a sequence from 10 to 100
% 4. create a sequence from 1 to 11 in steps of 2
% 5. create a backward sequence from 10 to 1 in steps of 1

sequence = 1:10;

%% Determine the size of vectors and matrices

% size() tells us the dimensions of an array
disp('Size of row vector:')
disp(size(rowVec))  % [1 × 5] means 1 row, 5 columns

disp('Size of column vector:')
disp(size(colVec))  % [5 × 1] means 5 rows, 1 column

disp('Size of matrix:')
disp(size(mat))  % [3 × 3] means 3 rows, 3 columns

%% Indexing: Accessing Specific Elements

% Access single element: arrayName(row, column)
disp('Element at row 2, column 3 of matrix:')
disp(mat(2, 3))  % Should be 6

% Access entire row - use : for "all columns"
disp('Entire row 2:')
disp(mat(2, :))  % [4, 5, 6]

% Access entire column - use : for "all rows"
disp('Entire column 3:')
disp(mat(:, 3))  % [3; 6; 9]

% Access range of elements
disp('Elements 2 to 4 from row vector:')
disp(rowVec(2:4))  % [2, 3, 4]

% Access specific indices
disp('Elements 1, 3, and 5 from row vector:')
disp(rowVec([1, 3, 5]))  % [1, 3, 5]

%% Random sequences

randSequence = randn(1,12);  % 1 row, 12 columns of random numbers


%% Basic Plotting
% This cell shows how to create basic plots in MATLAB.

x = 0:0.1:2*pi;
y = sin(x);

figure; % Create a new figure window
plot(x, y)

% let's improve this figure by adding axis labels, grid, and title
% title('Sine Wave')
% xlabel('x')
% ylabel('sin(x)')
% grid on

%% "For" loops
% 1. 

numIterations = 10;
for idx = 1:numIterations
    disp(idx)
    pause(0.5)
end

%% User Input

user_name = input('What is your name? ', 's');
disp(['Hello, ', user_name, '!']);

%% if...else statements
% 1. experiment with this code using the input() function.
% 2. what if you enter the number 0? Remember, the code is not always
% correct, but it does whay you instruct it to do
% 3. what if you enter a string?

x = input('Enter a number: ');
if x > 0
    disp('The number is positive.');
else
    disp('The number is negative');
end

%% for loops and and if statements combined

numIterations = 10;
for idx = 1:numIterations
    
    if idx <= 5
        disp([idx ' is less than or equal to 5'])
    else
        disp([idx ' is greater than 5'])
    end
    pause(1)
end

% why did it not work as expected?

%% Conclusion
% This cell concludes the basic introduction to MATLAB.

disp('This concludes the basic introduction to MATLAB. Happy coding!')