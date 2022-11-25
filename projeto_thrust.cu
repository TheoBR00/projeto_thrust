#include <iostream>
#include <fstream>
#include <vector>
#include <numeric>
#include <algorithm>
#include <random>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/functional.h>
#include <thrust/transform.h>
#include <thrust/random.h>
#include <thrust/shuffle.h>
#include <thrust/fill.h>
#include <thrust/execution_policy.h>

using namespace std;

struct graph{
    int id;
    float x;
    float y;
    bool vis;
};

struct ponto{
    int id;
    float x;
    float y;
    //float d;
};

struct dist_calc
{
  graph *vetor;
  dist_calc(graph *vetor_) : vetor(vetor_) {};
  __device__
  float operator()(int ind){
    return sqrt(pow(static_cast<graph>(vetor[ind]).x - vetor[ind+1].x, 2) + pow(static_cast<graph>(vetor[ind]).y - vetor[ind+1].y, 2));
  }
};


struct swap_vec
{
  graph *vetor;
  unsigned int n;
  swap_vec(graph *vetor_n, unsigned int n) : vetor(vetor_n), n(n) {};
  __device__
  float operator()(int posi){

    float dist = 10000000;

    float d;

    //return swap(static_cast<graph>(vetor[posi]), static_cast<graph>(vetor[posi+1]));

    for(int ct = 0; ct < posi; ct++){

      for(int ct_2 = 0; ct_2 < n-1; ct_2++){
        graph p1 = vetor[ct_2];
        graph p2 = vetor[ct_2+1];
        vetor[ct_2] = p2;
        vetor[ct_2+1] = p1;

        d = sqrt(pow(vetor[ct_2].x - vetor[ct_2+1].x, 2) + pow(vetor[ct_2].y - vetor[ct_2+1].y, 2));

        if(d < dist){
          dist = d;
        }
      }
      return d;
    }

  }
};

//float __device__ dist_calc(int ind){

//  return sqrt(pow(raw_cast<graph>(p1).x - p2.x, 2) + pow(raw_cast<graph>(p1).y - p2.y, 2));

//}


int main(){

    std::cout << "Main" << std::endl;

    ofstream myfile;

    std::cout << "ofstream myfile" << std::endl;

    unsigned int n;

    

    float x0;
    float y0;
    //float x1;
    //float y1;
    
    std::cin >> n;

    std::cout << "Carregou n: " << n << std::endl;

    //float dist;

    //std::vector<int>vec_ids;

    thrust::device_vector<int> vec_ids(n);

    std::cout << "Criou vec_ids" << std::endl;

    int chegou = 0;

    //if(n - 1 == 1){
    //    std::cin >> x1;
    //    std::cin >> y1;

    //    dist = sqrt(pow(x0 - x1, 2) + pow(y0 - y1, 2));
    //    return dist;
    //}

    bool status = true;

    //std::vector<graph> vec_pontos;

    thrust::device_vector<graph> vec_pontos(n);

    int i = 0;
    int pos = 0;

    thrust::device_vector<graph> array[10*n];

    thrust::device_vector<float> array_float[10*n];

    for(int r = 0; r < n; r++){
        std::cin >> x0;
        std::cin >> y0;

        graph g;
        g.id = r;
        g.x = x0;
        g.y = y0;
        g.vis = false;

        vec_pontos[r] = g;

    }

    for(int b = 0; b < n; b++){
        //std::cout << "id: " << vec_pontos[b].id << endl;
    }

    int num = 0;
    int count = 0;
    int sw = 0;

    float d_total = 0.0;

    //std::default_random_engine e(seed);
    thrust::random::default_random_engine generator;
    thrust::uniform_int_distribution<int> distribution(1,10);

    float d_a = 10000000.0;


    thrust::device_vector<graph> vec(n);

    //std::vector<graph> vec;
    

    for(int rodada = 0; rodada < 10; rodada++){
        auto sorteia = distribution(generator);
        std::cout << "random: " << sorteia << endl;

        std::cout << "Antes do shuffle" << std::endl;

        for(int vetores = 0; vetores < 10*n; vetores++){

          array[vetores] = thrust::device_vector<graph>(n);

          for(int sr = 0; sr < n; sr++){
            array[vetores][sr] = vec_pontos[sr];
          }

          thrust::shuffle(thrust::device, array[vetores].begin(), array[vetores].end(), generator);

          thrust::shuffle(thrust::device, vec_pontos.begin(), vec_pontos.end(), generator);

        }

        for(int lm = 0; lm < 10*n; lm++){
          std::cout << " " << std::endl;
          for(int k = 0; k < n; k++){
            std::cout << "VETORES[lm" << "] " << "= " << static_cast<graph>(array[lm][k]).id << std::endl;

            }
          }

          std::cout << " " << std::endl;

        //thrust::shuffle(thrust::device, vec_pontos.begin(), vec_pontos.end(), generator);

        std::cout << "Depois do shuffle" << std::endl;

        //std::shuffle(vec_pontos.begin(), vec_pontos.end(), default_random_engine(sorteia));
        status = true;

        count = 0;

        chegou = 0;
    
        float d_to = 0;

        //for(int contagem = 0; contagem < n; contagem++){
            //std::cout << vec_pontos[contagem].x << " " << vec_pontos[contagem].y << endl;
        //}

        while(status){

            if(count == n-1){
                status = false;
            }

            d_to = 0;

            //std::cout << "d_to = " << d_to << std::endl;

            //std::cout << "Reiniciou" << endl;

            thrust::device_vector<float> vec_dists(n);

            for(i = 0; i < n; i++){

                std::cout << "Pegou pontos" << std::endl;
                
                if(static_cast<graph>(vec_pontos[i]).vis == false && i < n-1) {

                    thrust::counting_iterator<int> iter(0);

                    thrust::transform(iter, iter+(n-1), vec_pontos.begin(), dist_calc(thrust::raw_pointer_cast(vec_pontos.data())));

                    for(int tam = 0; tam < n; tam++){
                      std::cout << "vec_dists = " << vec_dists[tam] << std::endl;
                    }

                    //float d_novo = sqrt(pow(static_cast<graph>(vec_pontos[i]).x - p1.x, 2) + pow(static_cast<graph>(vec_pontos[i]).y - p1.y, 2));
                    //d_to += d_novo;
                    //std::cout << "d_novo: " << d_novo << endl;
                    //std::cout << vec_pontos[i].x << vec_pontos[i].y << " " << p1.x << p1.y << endl;
                    std::cout << "i: " << i << endl;

                    //if(d_novo < d_a){
                    //    d_a = d_novo;
                        //num = i;
                    //}

                }

                if(i == n-1){
                  std::cout << "i == n - 1" << std::endl;
                  //d_to += sqrt(pow(static_cast<graph>(vec_pontos[i]).x - static_cast<graph>(vec_pontos[0]).x, 2) + pow(static_cast<graph>(vec_pontos[i]).y - static_cast<graph>(vec_pontos[0]).y, 2));
                  //std::cout << "i: " << i << endl;
                  std::cout << "d_to: " << d_to << endl;
                }

                //d_to = d_novo;



            }

            std::cout << "Percorreu for" << std::endl;

            if(d_to <= d_a){
                thrust::device_vector<graph> vec(n);
                d_a = d_to;
                for(int u = 0; u < n; u++){
                    //vec.push_back(vec_pontos[u]);
                    vec[u] = vec_pontos[u];
                }
                //d_total += d_a;
                //std::cout << "d_total: " << d_total << endl;
            }
            
            //vec_ids.push_back(vec_pontos[pos].id);
            std::cout << "Antes do static cast" << std::endl;
            vec_ids[count] = static_cast<graph>(vec_pontos[pos]).id;
            std::cout << "Fez static cast" << std::endl;



            //vec_pontos[pos].vis = true;

            //if(count == n-1){
            //    swap(vec_pontos[count], vec_pontos[0]);
            //}

            if(count < n-1){

                //swap(vec_pontos[count], vec_pontos[count+1]);

                thrust::counting_iterator<float> iterador(0);

                thrust::transform(iterador, iterador+(n-1), array_float.begin(), swap_vec(thrust::raw_pointer_cast(array.data())));
                for(int it = 0; it < n; it++){
                  std::cout << "swap vec_pontos: " << static_cast<graph>(vec_pontos[it]).id << std::endl;
                }
            }
            
                

            for(int sw = 0; sw < n; sw++){
                //std::cout << "swap: " << vec_pontos[sw].x << " " << vec_pontos[sw].y << endl;
            }

            std::cerr << "local: "  << d_to << " ";
            for(int erros = 0; erros < n; erros++){
                //std::cout << vec_pontos[erros].x << " " << vec_pontos[erros].y << endl;
                std::cerr << static_cast<graph>(vec_pontos[erros]).id << " ";
            }
            std::cerr << endl;

            count++;

            //pos = num;

            //if(count == n){
            //    float d_f = sqrt(pow(vec_pontos[pos].x - vec_pontos[0].x, 2) + pow(vec_pontos[pos].y - vec_pontos[0].y, 2));
            //    std::cout << "d_f: " << d_f << endl;
            //    d_to += d_f;

            //    std::cout << "d: "<< d_to << " " << 0 << endl;

            //    std::cout << endl;

            //    if(chegou == n-1){
            //        std::cout << "Trocou final" << endl;
            //        swap(vec_pontos[chegou], vec_pontos[0]);

            //        for(int posi = 0; posi < n; posi++){
            //            std::cout << "swap: " <<vec_pontos[posi].x << " " << vec_pontos[posi].y << endl;
            //        }

            //        std::cout << "Terminou swap" << endl;

            //        chegou = 0;
            //        sw = 0;
            //        status = false;
            //    }

            //    else{
            //        for(int vef = 0; vef < n; vef++){
            //            vec_pontos[vef].vis = false;
            //        }
            //        if(chegou < n-1){
            //            swap(vec_pontos[chegou], vec_pontos[chegou+1]);
            //        }
                    
            //        std::cout << "Chegou: " << chegou << endl;

            //        for(sw = 0; sw < n; sw++){
            //            std::cout << "swap: " <<vec_pontos[sw].x << " " << vec_pontos[sw].y << endl;
            //        }
            //        pos = 0;
            //        num = 0;

            //    }
                
            //    chegou++;

            //    count = 0;

            //    d_total = 0;

            //    std::vector<int>vec_ids;
                
            //}


            //std::vector<ponto>vec;

        }
    }

    std::cout << d_a << " " << 0 << endl;

    for(int min = 0; min < n; min++){
        std::cout << static_cast<graph>(vec[min]).id << " ";
    }
    std::cout << endl;
    
}