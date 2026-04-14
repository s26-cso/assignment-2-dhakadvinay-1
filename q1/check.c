#include <stdio.h>
#include <stdlib.h>

// This struct MUST match the assembly layout
struct Node {
    int val;
    int padding;        // Add explicit padding to align with assembly
    struct Node* left;
    struct Node* right;
};

extern struct Node* make_node(int val);
extern struct Node* insert(struct Node* root, int val);
extern struct Node* get(struct Node* root, int val);
extern int getAtMost(int val, struct Node* root);

int main() {
    printf("=== Test make_node ===\n");
    struct Node* n = make_node(42);
    printf("make_node(42): val=%d, left=%p, right=%p\n", n->val, n->left, n->right);

    printf("\n=== Test insert ===\n");
    struct Node* root = NULL;
    root = insert(root, 50);
    root = insert(root, 30);
    root = insert(root, 70);
    root = insert(root, 20);
    root = insert(root, 40);
    root = insert(root, 60);
    root = insert(root, 80);

    printf("Root: %d\n", root->val);
    printf("Root->left: %d\n", root->left->val);
    printf("Root->right: %d\n", root->right->val);
    printf("Root->left->left: %d\n", root->left->left->val);
    printf("Root->left->right: %d\n", root->left->right->val);
    printf("Root->right->left: %d\n", root->right->left->val);
    printf("Root->right->right: %d\n", root->right->right->val);

    printf("\n=== Test get ===\n");
    struct Node* found = get(root, 40);
    printf("get(root, 40): %s (val=%d)\n", found ? "FOUND" : "NOT FOUND", found ? found->val : -1);
    
    struct Node* notfound = get(root, 99);
    printf("get(root, 99): %s\n", notfound ? "FOUND" : "NOT FOUND");

    printf("\n=== Test getAtMost ===\n");
    printf("getAtMost(45, root): %d\n", getAtMost(45, root));
    printf("getAtMost(60, root): %d\n", getAtMost(60, root));
    printf("getAtMost(10, root): %d\n", getAtMost(10, root));
    printf("getAtMost(80, root): %d\n", getAtMost(80, root));
    printf("getAtMost(55, root): %d\n", getAtMost(55, root));

    return 0;
}