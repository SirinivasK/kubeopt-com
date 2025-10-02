# Startup Cost Optimization Guide

## 💰 Estimated Monthly Costs

| Component | Standard Config | Optimized Config | Savings |
|-----------|----------------|------------------|---------|
| AKS Cluster | $73/month | **$0/month** | $73 |
| VM Nodes (Standard_B2s) | $31-62/month | **$6-12/month** | 80% |
| Spot Instances | N/A | **$2-4/month** | Additional savings |
| Container Registry | $20/month | **$5/month** | $15 |
| Load Balancer | $18/month | **$18/month** | $0 |
| **Total Estimated** | **$142-173/month** | **$31-39/month** | **75-80%** |

## 🚀 Key Optimizations Applied

### 1. Virtual Machine Sizing
- **VM Type**: `Standard_B2s` (Burstable performance)
- **Specs**: 2 vCPU, 4GB RAM
- **Cost**: ~$31/month per node (vs $73 for Standard_D2s_v3)

### 2. Spot Instances (Enabled by default)
- **Savings**: 60-80% off regular pricing
- **Max Price**: $0.05/hour (~$36/month maximum)
- **Trade-off**: Can be evicted with 30s notice

### 3. Minimal Node Configuration
- **Default Pool**: 1 node (min: 1, max: 2)
- **Spot Pool**: 0-3 nodes as needed
- **Disk**: Ephemeral storage (cheaper than managed disks)

### 4. Container Registry
- **SKU**: Basic (vs Standard)
- **Cost**: $5/month (vs $20/month)

### 5. Resource Limits
- **CPU Request**: 50m (vs 100m)
- **Memory Request**: 64Mi (vs 128Mi)
- **Pod Replicas**: 1 (vs 2-3)

## 📊 Scaling Strategy

### Phase 1: MVP Launch
- 1 regular node + spot instances
- Single pod replica
- Basic monitoring
- **Est. Cost**: $25-35/month

### Phase 2: Growth
- Add second regular node
- Increase pod replicas
- Enhanced monitoring
- **Est. Cost**: $50-70/month

### Phase 3: Scale
- Upgrade to Standard VMs
- Multiple node pools
- Premium features
- **Est. Cost**: $100+/month

## ⚠️ Trade-offs and Considerations

### Spot Instance Limitations
- **Eviction**: 30-second notice when Azure needs capacity
- **Availability**: Not guaranteed in all regions/VM sizes
- **Workload**: Best for stateless applications

### Burstable VMs (B-series)
- **Performance**: CPU credits system
- **Best for**: Web applications with variable load
- **Limitation**: Sustained high CPU may exhaust credits

### Single Replica
- **Risk**: No redundancy during deployments
- **Mitigation**: Use rolling updates, health checks

## 🔧 Quick Wins for Additional Savings

1. **Reserved Instances**: 1-3 year commitments for 30-70% savings
2. **Azure Credits**: Startup programs, free tier
3. **Resource Scheduling**: Scale down non-prod environments
4. **Monitoring**: Set up cost alerts and budgets

## 🚨 Cost Monitoring Commands

```bash
# Check current spending
az consumption usage list --top 10

# Set up budget alerts
az consumption budget create \
  --budget-name "kubeopt-monthly" \
  --amount 50 \
  --time-grain Monthly

# Monitor spot instance pricing
az vm list-skus --location eastus --size Standard_B --output table
```

## 📈 Scaling Commands

```bash
# Scale up manually if needed
kubectl scale deployment kubeopt-website --replicas=2

# Scale nodes manually
az aks nodepool scale \
  --resource-group rg-kubeopt-com \
  --cluster-name aks-kubeopt-com \
  --name default \
  --node-count 2
```

## 💡 Startup Tips

1. **Start Small**: Use the optimized config first
2. **Monitor**: Watch performance and costs closely
3. **Scale Gradually**: Add resources only when needed
4. **Use Free Tier**: Leverage Azure free credits
5. **Regular Reviews**: Monthly cost analysis and optimization