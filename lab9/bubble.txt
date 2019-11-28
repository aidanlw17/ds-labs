void swap(int *x1, int *x2) {
    int tmp=*x1; 
    *x1=*x2; 
    *x2 = tmp; 
} 

void bubbleSort(int arr[], int n) {
   int i, k; 
   for (i = 0; i < n-1; i++){     
       for(k=0; k<n-i-1; k++){
           if (arr[j] > arr[j+1]) 
              swap(&arr[j], &arr[j+1]); 
       }
   }
}
